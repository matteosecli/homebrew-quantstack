class XtensorFftw < Formula
  desc "FFTW bindings for the xtensor C++14 multi-dimensional array library"
  homepage "http://xtensor-blas.readthedocs.io/en/latest/"
  url "https://github.com/xtensor-stack/xtensor-fftw/archive/0.2.6.tar.gz"
  sha256 "82d7492db4ae5593c2e419ddf1ece660ee315b269bc9e90176812e21d47bae3b"
  head "https://github.com/xtensor-stack/xtensor-fftw.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "xtl"
  depends_on "matteosecli/quantstack/xtensor"
  depends_on "fftw"

  def install
    mkdir "build" do
      system "cmake", "..",
            "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
            "-Dxtensor_DIR=#{Formula["xtensor"].lib}/cmake/xtensor",
            "-DFFTW_ROOT=#{Formula["fftw"].prefix}",
            "-DBUILD_TESTS=OFF",
            *std_cmake_args
      system "make", "install"
    end
  end

    test do
      (testpath/"test.cpp").write <<~EOS
        #include <xtensor-fftw/basic.hpp>   // rfft, irfft
        #include <xtensor-fftw/helper.hpp>  // rfftscale
        #include <xtensor/xarray.hpp>
        #include <xtensor/xbuilder.hpp>     // xt::arange
        #include <xtensor/xmath.hpp>        // xt::sin, cos
        #include <complex>
        #include <xtensor/xio.hpp>

        int main() {
          // generate a sinusoid field
          double dx = M_PI / 100;
          xt::xarray<double> x = xt::arange(0., 2 * M_PI, dx);
          xt::xarray<double> sin_x = xt::sin(x);

          // transform to Fourier space
          auto sin_fs = xt::fftw::rfft(sin_x);

          // multiply by i*k
          std::complex<double> i {0, 1};
          auto k = xt::fftw::rfftscale<double>(sin_x.shape()[0], dx);
          xt::xarray<std::complex<double>> sin_derivative_fs = xt::eval(i * k * sin_fs);

          // transform back to normal space
          auto sin_derivative = xt::fftw::irfft(sin_derivative_fs);

          return xt::allclose( xt::cos(x), sin_derivative ) ? 0 : 1;
        }
      EOS
      system ENV.cxx, "test.cpp", "-I#{include}", "-L#{Formula["fftw"].lib}", "-lfftw3", "-std=c++14", "-o", "test"
      system "./test"
    end
  end
