class Augustus < Formula
  desc "Predict genes in eukaryotic genomic sequences"
  homepage "http://bioinf.uni-greifswald.de/augustus/"
  url "http://bioinf.uni-greifswald.de/augustus/binaries/augustus-3.3.tar.gz"
  sha256 "b5eb811a4c33a2cc3bbd16355e19d530eeac6d1ac923e59f48d7a79f396234ee"
  revision 1 unless OS.mac?

  bottle do
    cellar :any
    sha256 "628ec61d36ac8c0cfa088bf0aaf8facb59888d8df407027d6099385a97da9a5a" => :high_sierra
    sha256 "8e6f909d5feb3a6890935646d31b70d99f7faf9315c0613c4362af3d19912c1f" => :sierra
    sha256 "57d0cdab04164c968240245b95159b21e464d7988dd4063d758dbfbb93e1b25a" => :el_capitan
    sha256 "f421982ad90c1d4507834102f0fb8183273c5b0e751392af0e2031460f391753" => :x86_64_linux
  end

  depends_on "boost"
  unless OS.mac?
    depends_on "bamtools"
    depends_on "zlib"
  end

  def install
    unless OS.mac?
      # Fix error: api/BamReader.h: No such file or directory
      inreplace "auxprogs/bam2hints/Makefile",
        "INCLUDES = /usr/include/bamtools",
        "INCLUDES = #{Formula["bamtools"].include/"bamtools"}"
      inreplace "auxprogs/filterBam/src/Makefile",
        "BAMTOOLS = /usr/include/bamtools",
        "BAMTOOLS= #{Formula["bamtools"].include/"bamtools"}"
    end

    # Prevent symlinking into /usr/local/bin/
    inreplace "Makefile", %r{ln -sf.*/usr/local/bin/}, "#ln -sf"

    # Compile executables for macOS. Tarball ships with executables for Linux.
    system "make", "clean" unless OS.mac?
    system "make"

    system "make", "install", "INSTALLDIR=#{prefix}"
    bin.env_script_all_files libexec/"bin", :AUGUSTUS_CONFIG_PATH => prefix/"config"
  end

  test do
    (testpath/"test.fasta").write <<~EOS
      >U00096.2:1-70
      AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC
    EOS
    cmd = "#{bin}/augustus --species=human test.fasta"
    assert_match "Predicted genes", shell_output(cmd)
  end
end
