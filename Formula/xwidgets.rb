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
  depends_on "zeromq" => :test

  resource "widgetsnbextension" do
    url "https://files.pythonhosted.org/packages/e0/c4/b7211bfc8e998fe55764539d2b169fb200e6427dfe4e62d1d83013caa9ef/widgetsnbextension-3.5.1.tar.gz"
    sha256 "079f87d87270bce047512400efd70238820751a11d2d8cb137a5a5bdbaf255c7"
  end

  def install
    # Install "widgetsnbextension" Jupyter Classic Notebook extension.
    # Jupyter is not needed to install the extension, but of course it's needed to use it.
    # Might clash with pip-installed "widgetsnbextension".
    # Consider moving in a separate package (that does not depend explicitely on "jupyterlab")
    # and then make "xwidgets" dependent on this separate package.
    # Alternatively, make a PR homebrew/core "jupyterlab" Formula to include "widgetsnbextension".
    resource("widgetsnbextension").stage do
      (prefix/"share/jupyter/nbextensions/jupyter-js-widgets/").install "widgetsnbextension/static/extension.js"
      (prefix/"share/jupyter/nbextensions/jupyter-js-widgets/").install "widgetsnbextension/static/extension.js.map"
      (prefix/"etc/jupyter/nbconfig/notebook.d/").install "widgetsnbextension.json"
    end
       
    mkdir "build" do
      system "cmake", "..",
            "-Dxtl_DIR=#{Formula["xtl"].lib}/cmake/xtl",
            "-Dxproperty_DIR=#{Formula["xproperty"].lib}/cmake/xproperty",
            "-Dnlohmann_json_DIR=#{Formula["nlohmann_json"].lib}/cmake/nlohmann_json",
            "-Dxeus_DIR=#{Formula["xeus"].lib}/cmake/xeus",
            *std_cmake_args
      system "make", "install"
    end
 end

  def caveats
    <<~EOS
      This package installs the backend extension and tries to install and activate
      the Jupyter Classic Notebook frontend extension.
      If you already have Jupyter with a properly working extension (e.g. if you
      already use "ipywidgets" you shoud have it, check for "jupyter-js-widgets"
      in the output of "jupyter nbextension list"), then you can ignore the
      Homebrew link warnings about conflicting files.
      If you don't have Jupyter or your Jupyter installation is old / broken / in a
      non-standard path, you have to install and activate the frontend extension
      yourself. On a recent enough version of Jupyter, it should be enough to do:

        pip install widgetsnbextension

      where the "pip" binary should match the one that installed Jupyter itself.
      If Jupyter still doesn't find the extension, you may need to use an additional
      "--user" or "--sys-prefix" at the end of the above command, depending on how
      Jupyter is installed.
      
      If you instead prefer to use JupyterLab over Classic Notebook, forget all the
      above and just install the extension with this much simpler command:

        jupyter labextension install @jupyter-widgets/jupyterlab-manager
       
      or via the grafical extension manager in JupyterLab.
        
      More info on extensions can be found at:
      
        (Classic Notebook)  https://jupyter-notebook.readthedocs.io/en/stable/extending/frontend_extensions.html
        (JupyterLab)        https://jupyterlab.readthedocs.io/en/stable/user/extensions.html
        
    EOS
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <map>
      #include <string>

      #include "xwidgets/xbutton.hpp"
      
      using namespace xw;

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
    system ENV.cxx, "test.cpp", "-I#{include}",
                                "-L#{lib}", "-lxwidgets",
                                "-L#{Formula["xeus"].lib}", "-lxeus",
                                "-L#{Formula["zeromq"].lib}", "-lzmq",
                                "-std=c++14", "-o", "test"
    system "./test"
  end
end
