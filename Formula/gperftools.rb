class Gperftools < Formula
  desc "Multi-threaded malloc() and performance analysis tools"
  homepage "https://github.com/gperftools/gperftools"
  url "https://github.com/gperftools/gperftools/releases/download/gperftools-2.6.3/gperftools-2.6.3.tar.gz"
  sha256 "314b2ff6ed95cc0763704efb4fb72d0139e1c381069b9e17a619006bee8eee9f"

  bottle do
    cellar :any
    sha256 "0d36f2291e12318c900358e5c5b38d1322533173d66cc64ec17e404333b40a70" => :high_sierra
    sha256 "498699638aa7e06c11c7ceee5b7c4bb96eaffa02ef0fe043b22140fe5f22c575" => :sierra
    sha256 "d91d9e54d3522a3c6aca928660d6521455fa2ddc21e766e8f386fd58ebaac17b" => :el_capitan
    sha256 "787b40a79120e581fae120c2301ad580ba2cdd6e4e103e549b79a119a0689460" => :x86_64_linux
  end

  # Fix error: No frame pointers and no libunwind. The compilation will fail
  depends_on "libunwind" unless OS.mac?

  head do
    url "https://github.com/gperftools/gperftools.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    # Fix "error: unknown type name 'mach_port_t'"
    ENV["SDKROOT"] = MacOS.sdk_path if MacOS.version == :sierra

    if OS.mac?
      ENV.append_to_cflags "-D_XOPEN_SOURCE"
    else
      ENV.append_to_cflags "-I#{Formula["libunwind"].opt_prefix}/include"
      ENV["LDFLAGS"] = "-L#{Formula["libunwind"].opt_prefix}/lib"
    end

    system "autoreconf", "-fiv" if build.head?
    if OS.mac?
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
    else
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}",
                            "--enable-libunwind"
    end
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <gperftools/tcmalloc.h>

      int main()
      {
        void *p1 = tc_malloc(10);
        assert(p1 != NULL);

        tc_free(p1);

        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-ltcmalloc", "-o", "test"
    system "./test"
  end
end
