class Xtensor < Formula
  desc "C++ tensors with broadcasting and lazy computing"
  homepage "https://xtensor.readthedocs.io/en/latest/"
  url "https://github.com/xtensor-stack/xtensor/archive/0.21.9.tar.gz"
  sha256 "845cd3cc4f4992be7425b5f44a015181415cdb35d10f73ddbc8d433e331dc740"
  head "https://github.com/xtensor-stack/xtensor.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "xtl"
  depends_on "matteosecli/quantstack/xsimd"

  def install
    mkdir "build" do
      system "cmake", "..",
            "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
            "-DXTENSOR_USE_XSIMD=ON",
            *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include "xtensor/xarray.hpp"
      #include "xtensor/xio.hpp"
      #include "xtensor/xview.hpp"

      int main()
      {
        xt::xarray<double> arr1
          {{11.0, 12.0, 13.0},
           {21.0, 22.0, 23.0},
           {31.0, 32.0, 33.0}};

        xt::xarray<double> arr2
          {100.0, 200.0, 300.0};

        xt::xarray<double> result = xt::view(arr1, 1) + arr2;
        
        xt::xarray<double> expected
          {121.0, 222.0, 323.0};

        std::cout << result(2) << std::endl;
        
        return xt::allclose( result, expected ) ? 0 : 1;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++14", "-o", "test"
    assert_equal "323", shell_output("./test").chomp
  end
end
