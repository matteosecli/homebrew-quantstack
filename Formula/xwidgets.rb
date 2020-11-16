class Xwidgets < Formula
  desc "C++ backend for Jupyter interactive widgets"
  homepage "https://xwidgets.readthedocs.io/en/latest/"
  url "https://github.com/jupyter-xeus/xwidgets/archive/0.24.0.tar.gz"
  sha256 "8f4a9849478c07d742f8ed1b889dedf0d4271729c90a7b0b691b5990e277d4b9"
  head "https://github.com/jupyter-xeus/xwidgets.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "xtl"
  depends_on "xproperty"
  depends_on "nlohmann_json"
  depends_on "xeus"

  def install
    mkdir "build" do
      system "cmake", "..",
            "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
            "-Dxproperty_DIR=#{Formula["xproperty"].lib}/cmake/xproperty",
            "-Dnlohmann_json_DIR=#{Formula["nlohmann_json"].lib}/cmake/nlohmann_json",
            "-Dxeus_DIR=#{Formula["xproperty"].lib}/cmake/xeus",
            *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <map>
      #include <string>

      #include "xwidgets/xbutton.hpp"

      int main()
      {
        std::map<std::string, xholder> hm;
        
        button b;
        std::string desc = "coincoin";
        b.description = desc;
        
        hm["x"] = std::move(b);
        std::string res = hm["x"].template get<button>().description();
        
        return ( desc == res ) ? 0 : 1;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++14", "-o", "test"
    system "./test"
  end
end
