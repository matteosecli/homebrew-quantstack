class Xproperty < Formula
  desc "Traitlets-like C++ properties and implementation of the observer pattern"
  homepage "https://xproperty.readthedocs.io/en/latest/"
  url "https://github.com/jupyter-xeus/xproperty/archive/0.10.4.tar.gz"
  sha256 "3b050dc58c78003117266e593e11fb67cf8dee7051fb0029ae0d09f6b22d598e"
  head "https://github.com/jupyter-xeus/xproperty.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  depends_on "xtl"

  def install
    mkdir "build" do
      system "cmake", "..",
             "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
            "-DBUILD_TESTS=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <stdexcept>

      #include "xproperty/xobserved.hpp"

      struct Foo : public xp::xobserved<Foo>
      {
          XPROPERTY(int, Foo, bar);
          XPROPERTY(int, Foo, baz);
      };

      int main()
      {
        Foo foo;

        XOBSERVE(foo, bar, [](Foo& f)
        {
            std::cout << "Observer: New value of bar: " << f.bar << std::endl;
        });

        XVALIDATE(foo, bar, [](Foo&, double& proposal)
        {
            std::cout << "Validator: Proposal: " << proposal << std::endl;
            if (proposal < 0)
            {
                throw std::runtime_error("Only non-negative values are valid.");
            }
            return proposal;
        });
        
        foo.bar = 1;                             // Assigning a valid value
                                                 // The notifier prints "Observer: New value of bar: 1"
        std::cout << foo.bar << std::endl;       // Outputs 1.0

        try
        {
            foo.bar = -1;                        // Assigning an invalid value
        }
        catch (...)
        {
            std::cout << foo.bar << std::endl;   // Still outputs 1
        }
        
        return ( foo.bar == 1 ) ? 0 : 1;
      }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-std=c++14", "-o", "test"
    system "./test"
  end
end
