class XtensorBlas < Formula
  desc "BLAS extension to xtensor"
  homepage "http://xtensor-blas.readthedocs.io/en/latest/"
  url "https://github.com/xtensor-stack/xtensor-blas/archive/0.17.2.tar.gz"
  sha256 "2798c7e230d0c4b2d357bba20a0ef23a2b774d892be31ebbf702cb9935ea9f64"
  head "https://github.com/xtensor-stack/xtensor-blas.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "matteosecli/quantstack/xtensor"
  depends_on "openblas"

  def install
    mkdir "build" do
      system "cmake", "..",
            "-Dxtensor_DIR=#{Formula["xtensor"].lib}/cmake/xtensor",
            "-DOpenBLAS_DIR_DIR=#{Formula["openblas"].lib}/cmake/openblas",
            "-DBUILD_TESTS=OFF",
            *std_cmake_args
      system "make", "install"
    end
  end

    test do
      (testpath/"test.cpp").write <<~EOS
        #include "xtensor/xarray.hpp"
        #include "xtensor/xview.hpp"
        #include "xtensor/xbuilder.hpp"
        #include "xtensor/xcomplex.hpp"

        #include "xtensor-blas/xblas.hpp"
        #include "xtensor-blas/xlapack.hpp"
        #include "xtensor-blas/xlinalg.hpp"

        #include "xtensor/xio.hpp"

        using namespace std::complex_literals;

        using namespace xt;

        int main(void) {
          xarray<double> eig_arg_0 = {{ 0.89342434, 0.96630682, 0.83113658, 0.9014204 , 0.17622395},
                                      { 0.01114647, 0.93096724, 0.35509599, 0.35329223, 0.65759337},
                                      { 0.27868701, 0.376794  , 0.63310696, 0.90892131, 0.35454718},
                                      { 0.02962539, 0.20561053, 0.2004051 , 0.83641883, 0.08335324},
                                      { 0.76958296, 0.23132089, 0.33539779, 0.70616527, 0.40256713}};
          auto eig_res = xt::linalg::eig(eig_arg_0);

          xtensor<std::complex<double>, 1> eig_expected_0 = { 2.24745601+0.i        , 0.24898158+0.51158566i, 0.24898158-0.51158566i,
                                                              0.66252212+0.i        , 0.28854321+0.i        };

          xtensor<std::complex<double>, 2> eig_expected_1 = {{-0.67843725+0.i        ,-0.00104977+0.50731553i,-0.00104977-0.50731553i,
                                                              -0.48456457+0.i        ,-0.11153304+0.i        },
                                                             {-0.38393722+0.i        ,-0.42892828-0.30675499i,-0.42892828+0.30675499i,
                                                              -0.60497432+0.i        ,-0.55233486+0.i        },
                                                             {-0.39453548+0.i        , 0.10153693-0.12657944i, 0.10153693+0.12657944i,
                                                               0.35111489+0.i        , 0.80267297+0.i        },
                                                             {-0.15349367+0.i        ,-0.04903747+0.08226059i,-0.04903747-0.08226059i,
                                                               0.48726345+0.i        ,-0.10533951+0.i        },
                                                             {-0.46162383+0.i        , 0.65501769+0.i        , 0.65501769-0.i        ,
                                                              -0.19620376+0.i        , 0.16463982+0.i        }};
          xarray<std::complex<double>> eigvals = std::get<0>(eig_res);
          xarray<std::complex<double>> eigvecs = std::get<1>(eig_res);

          bool res1 = allclose(xt::imag(eigvals), xt::imag(eig_expected_0));
          bool res2 = allclose(xt::real(eigvals), xt::real(eig_expected_0));
          bool res3 = allclose(abs(imag(eigvecs)), abs(imag(eig_expected_1)));
          bool res4 = allclose(abs(real(eigvecs)), abs(real(eig_expected_1)));
          
          return ( res1 && res2 && res3 && res4 ) ? 0 : 1;
        }
      EOS
      system ENV.cxx, "test.cpp", "-I#{include}", "-L#{Formula["openblas"].lib}", "-lopenblas", "-std=c++14", "-o", "test"
      system "./test"
    end
  end
