import Foundation

internal extension String {
    var urlPathEscaped: String {
        // this can only fail in very rare cases, basically if one wants it to fail only :P
        // https://stackoverflow.com/questions/33558933/why-is-the-return-value-of-string-addingpercentencoding-optional
        return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }

    var urlQueryEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
