class Xtl < Formula
  desc "The x template library"
  homepage "https://xtl.readthedocs.io/en/latest/"
  url "https://github.com/xtensor-stack/xtl/archive/0.6.21.tar.gz"
  sha256 "97137014fa5da2a3598a267d06c8e28490b2e1c75b8f52358738bedb526fc771"
  head "https://github.com/xtensor-stack/xtl.git"
  license "MIT"

  #keg_only "it conflicts with xtensor's built-in xtl"
  #conflicts_with "homebrew/core/xtensor", :because => "it conflicts with xtensor's built-in xtl"
  
  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "xtl/xplatform.hpp"
      
      int main()
      {
        #if defined(__BYTE_ORDER) && __BYTE_ORDER == __BIG_ENDIAN
          return ( xtl::endianness() == endian::big_endian );
        #endif
        #if defined(__BYTE_ORDER) && __BYTE_ORDER == __LITTLE_ENDIAN
          return ( xtl::endianness() == endian::little_endian );
        #endif
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++11", "-o", "test"
    system "./test"
  end
end
