class Vls.TextDocument : Object {
    public weak Compilation compilation { get; private set; }
    public string filename;

    public Vala.SourceFile file { get; private set; }
    public string uri { get; private set; }
    public int version;

    public string? content {
        get {
            return (string) file.get_mapped_contents ();
        }
        set {
            file.content = value;
        }
    }

    public string? package_name { get; private set; }

    public TextDocument (Compilation compilation,
                         string filename,
                         string? content = null,
                         int version = 0) throws ConvertError, FileError {

        if (!FileUtils.test (filename, FileTest.EXISTS)) {
            throw new FileError.NOENT ("file %s does not exist".printf (filename));
        }

        this.compilation = compilation;
        this.filename = filename;
        this.uri = Filename.to_uri (filename);
        this.version = version;

        var type = Vala.SourceFileType.NONE;
        if (uri.has_suffix (".vala") || uri.has_suffix (".gs"))
            type = Vala.SourceFileType.SOURCE;
        else if (uri.has_suffix (".vapi") || uri.has_suffix (".gir"))
            type = Vala.SourceFileType.PACKAGE;

        this.file = new Vala.SourceFile (compilation.code_context, type, filename, content);
        determine_package_name ();
    }

    /**
     * Create a TextDocument that wraps a Vala.SourceFile
     */
    public TextDocument.from_sourcefile (Compilation compilation,
                                         Vala.SourceFile file) throws ConvertError {
        this.compilation = compilation;
        this.filename = file.filename;
        this.uri = Filename.to_uri (file.filename);
        this.version = 0;
        this.file = file;
        determine_package_name ();
    }

    private void determine_package_name () {
        if (file.file_type == Vala.SourceFileType.PACKAGE) {
            var is_vapi = uri.has_suffix (".vapi");
            string package_name = Path.get_basename (filename);
            this.package_name = package_name.substring (0, package_name.length - (is_vapi ? ".vapi".length : ".gir".length));
        }
    }
}
