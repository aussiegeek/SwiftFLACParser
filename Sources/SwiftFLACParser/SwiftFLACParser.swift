import flac

public enum SwiftFLACParserError: Error {
    case statusOK
    case illegalInput
    case errorOpeningFile
    case notAFlacFile
    case notWritable
    case badMetadata
    case readError
    case seekError
    case writeError
    case renameError
    case unlinkError
    case memoryAllocationError
    case internalError

    fileprivate init(code: FLAC__Metadata_SimpleIteratorStatus) {
        switch code {
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_OK:
            self = .statusOK
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_ILLEGAL_INPUT:
            self = .illegalInput
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_ERROR_OPENING_FILE:
            self = .errorOpeningFile
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_NOT_A_FLAC_FILE:
            self = .notAFlacFile
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_NOT_WRITABLE:
            self = .notWritable
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_BAD_METADATA:
            self = .badMetadata
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_READ_ERROR:
            self = .readError
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_SEEK_ERROR:
            self = .seekError
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_WRITE_ERROR:
            self = .writeError
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_RENAME_ERROR:
            self = .renameError
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_UNLINK_ERROR:
            self = .unlinkError
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_MEMORY_ALLOCATION_ERROR:
            self = .memoryAllocationError
        case FLAC__METADATA_SIMPLE_ITERATOR_STATUS_INTERNAL_ERROR:
            self = .internalError
        default:
            self = .internalError
        }
    }
}

public class SwiftFLACParser {
    private let FLAC__false: FLAC__bool = 0
    private let FLAC__true: FLAC__bool = 1
    typealias VorbisCString = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?

    public var metadata: [String: String] = [:]

    public init(filename: String) throws {
        let iterator = FLAC__metadata_simple_iterator_new()

        guard iterator != nil else {
            throw SwiftFLACParserError.memoryAllocationError
        }

        // we own the iterator, free it at the end of the method
        defer { FLAC__metadata_simple_iterator_delete(iterator) }

        guard FLAC__metadata_simple_iterator_init(iterator, filename, FLAC__true, FLAC__true) == FLAC__true else {
            let status = FLAC__metadata_simple_iterator_status(iterator)
            throw SwiftFLACParserError(code: status)
        }

        parseMetaData(iterator)
    }

    private func parseMetaData(_ iterator: OpaquePointer?) {
        repeat {
            guard let blockPointer = FLAC__metadata_simple_iterator_get_block(iterator) else {
                continue
            }
            // we own the block pointer, free it at the end of this method
            defer { FLAC__metadata_object_delete(blockPointer) }
            let block = blockPointer.pointee
            switch block.type {
            case FLAC__METADATA_TYPE_VORBIS_COMMENT:
                parseVorbisComment(block)

            default: break
            }

        } while FLAC__metadata_simple_iterator_next(iterator) == FLAC__true
    }

    private func parseVorbisComment(_ block: FLAC__StreamMetadata) {
        let vorbisComment = block.data.vorbis_comment

        let numComments = vorbisComment.num_comments
        metadata = Dictionary(minimumCapacity: Int(numComments))

        let initialcommentsPointer = vorbisComment.comments!

        for i in 0 ..< vorbisComment.num_comments {
            let comment = initialcommentsPointer[Int(i)]

            if let entry = comment.entry {
                let actualString = String(cString: entry)
                let parts = actualString.split(separator: "=", maxSplits: 1)

                if parts.count == 2 {
                    metadata.updateValue(String(parts[1]), forKey: String(parts[0]))
                }
            }
        }
    }
}