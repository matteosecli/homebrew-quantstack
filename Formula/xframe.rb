class Xframe < Formula
  desc "C++ multi-dimensional labeled arrays and dataframe based on xtensor"
  homepage "https://xframe.readthedocs.io/en/latest/"
  url "https://github.com/xtensor-stack/xframe/archive/0.3.0.tar.gz"
  sha256 "1e8755b7a8b54dd8b7c7b65d99cc896e587ebf563c937f4aae1f73ad4f4c6be1"
  head "https://github.com/xtensor-stack/xframe.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "matteosecli/quantstack/xtensor"

  def install
    mkdir "build" do
      system "cmake", "..", "-DBUILD_TESTS=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <string>
      #include <iostream>

      #include "xtensor/xrandom.hpp"
      #include "xtensor/xmath.hpp"

      #include "xframe/xio.hpp"
      #include "xframe/xvariable.hpp"
      #include "xframe/xvariable_view.hpp"
      #include "xframe/xvariable_masked_view.hpp"
      #include "xframe/xreindex_view.hpp"

      using coordinate_type = xf::xcoordinate<xf::fstring>;
      using variable_type = xf::xvariable<double, coordinate_type>;
      using data_type = variable_type::data_type;

      int main(void) {
        data_type dry_temperature_data = xt::eval(xt::random::rand({6, 3}, 15., 25.));
        dry_temperature_data(0, 0).has_value() = false;
        dry_temperature_data(2, 1).has_value() = false;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++14", "-o", "test"
    system "./test"
  end
end
