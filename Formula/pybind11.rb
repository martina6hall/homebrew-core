class Pybind11 < Formula
  desc "Seamless operability between C++11 and Python"
  homepage "https://github.com/pybind/pybind11"
  url "https://github.com/pybind/pybind11/archive/v2.2.2.tar.gz"
  sha256 "b639a2b2cbf1c467849660801c4665ffc1a4d0a9e153ae1996ed6f21c492064e"

  bottle do
    cellar :any_skip_relocation
    sha256 "3d6838a32ea3e4ec46bb6d61cd583d156104b9c78692dfb127e6e07230d9c135" => :high_sierra
    sha256 "3d6838a32ea3e4ec46bb6d61cd583d156104b9c78692dfb127e6e07230d9c135" => :sierra
    sha256 "3d6838a32ea3e4ec46bb6d61cd583d156104b9c78692dfb127e6e07230d9c135" => :el_capitan
    sha256 "243485b62b96a25e53fd245b46adbd06f5aef0a0b5f4d14a219cab06bda3ca9c" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "python3"

  def install
    system "cmake", ".", "-DPYBIND11_TEST=OFF", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"example.cpp").write <<~EOS
      #include <pybind11/pybind11.h>

      int add(int i, int j) {
          return i + j;
      }
      namespace py = pybind11;
      PYBIND11_PLUGIN(example) {
          py::module m("example", "pybind11 example plugin");
          m.def("add", &add, "A function which adds two numbers");
          return m.ptr();
      }
    EOS

    (testpath/"example.py").write <<~EOS
      import example
      example.add(1,2)
    EOS

    python_flags = `python3-config --cflags --ldflags`.split(" ")
    system ENV.cxx, "-O3", "-shared", "-std=c++11", *python_flags, *("-fPIC" unless OS.mac?), "example.cpp", "-o", "example.so"
    system "python3", "example.py"
  end
end
