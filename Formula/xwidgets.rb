class Xwidgets < Formula
  #include Language::Python::Virtualenv
  desc "C++ backend for Jupyter interactive widgets"
  homepage "https://xwidgets.readthedocs.io/en/latest/"
  url "https://github.com/jupyter-xeus/xwidgets/archive/0.24.0.tar.gz"
  sha256 "8f4a9849478c07d742f8ed1b889dedf0d4271729c90a7b0b691b5990e277d4b9"
  head "https://github.com/jupyter-xeus/xwidgets.git"
  license "BSD-3-Clause"

  depends_on "cmake" => :build
  #depends_on "python@3.9"
  depends_on "xtl"
  depends_on "xproperty"
  depends_on "nlohmann_json"
  depends_on "xeus"
  depends_on "zeromq" => :test

  resource "widgetsnbextension" do
    url "https://files.pythonhosted.org/packages/e0/c4/b7211bfc8e998fe55764539d2b169fb200e6427dfe4e62d1d83013caa9ef/widgetsnbextension-3.5.1.tar.gz"
    sha256 "079f87d87270bce047512400efd70238820751a11d2d8cb137a5a5bdbaf255c7"
  end

#  resource "widgetsnbextension" do
#    url "https://files.pythonhosted.org/packages/6c/7b/7ac231c20d2d33c445eaacf8a433f4e22c60677eb9776c7c5262d7ddee2d/widgetsnbextension-3.5.1-py2.py3-none-any.whl"
#    sha256 "bd314f8ceb488571a5ffea6cc5b9fc6cba0adaf88a9d2386b93a489751938bcd"
#  end

  def install
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
    
#    # Install widgetsnbextension
#    venv = virtualenv_create(libexec, Formula["python@3.9"].opt_bin/"python3")
#    ENV["JUPYTER_PATH"] = etc/"jupyter"
#    venv.pip_install_and_link resource("widgetsnbextension")
#    (etc/"jupyter/nbconfig/notebook.d/").install_symlink libexec/"etc/jupyter/nbconfig/notebook.d/widgetsnbextension.json"
#    (share/"jupyter/nbextensions/").install_symlink libexec/"share/jupyter/nbextensions/jupyter-js-widgets"
 end
  
#  def post_install
#    found_jupyter   = "Jupyter binary found at: "
#    fail_jupyter    = "Cannot find an installation of Jupyter."
#    install_jupyter = "Please install Jupyter with your favorite package manager and then manually install and activate the front-end extension (see caveats)."
#
#    def install_nbextension(jupyter_bin)
#      install_classic = "Installing Classic Notebook frontend extension..."
#      install_lab     = "Installing JupyterLab frontend extension..."
#      success_classic = "Successfully installed Classic Notebook frontend extension."
#      success_lab     = "Successfully installed JupyterLab frontend extension."
#      fail_classic    = "Something went wrong when installing Classic Notebook frontend extension!"
#      fail_lab        = "Something went wrong when installing JupyterLab frontend extension!"
#      verify_jupyter  = "Please verify your Jupyter installation and then manually install and activate the frontend extension (see caveats)."
#
#      todevnull = "" #" 2> /dev/null" #(debug?) && "" || " 2> /dev/null"
#
#      # Classic Notebook
#      ohai install_classic
#      # ( `$(dirname $(head -1 $(which #{jupyter_bin}) | tr -d '#!'))/pip install widgetsnbextension` ) &&
#      #system(`dirname $(head -1 $(which #{jupyter_bin}) | tr -d '#!')`.chomp+"/pip", "install", "widgetsnbextension")
#      #if ( `$(dirname $(head -1 $(which #{jupyter_bin}) | tr -d '#!'))/pip install widgetsnbextension`; $?.success? )
#      #if system `dirname $(head -1 $(which #{jupyter_bin}) | tr -d '#!')`.chomp+"/pip", "-v", "install", "widgetsnbextension"
#      if ( ( `#{jupyter_bin} nbextension install --system --py "#{libexec}/lib/python3.9/site-packages/widgetsnbextension" #{todevnull}`; $?.success? ) && ( `#{jupyter_bin} nbextension enable --system --py widgetsnbextension #{todevnull}`;  $?.success? ) )
#        ohai success_classic
#      else
#        opoo fail_classic; opoo verify_jupyter;
#      end
#      # JupyterLab
#      ohai install_lab
#      if ( `#{jupyter_bin} labextension install --app-dir=#{share}/jupyter/lab @jupyter-widgets/jupyterlab-manager #{todevnull}`; $?.success? )
#        ohai success_lab
#      else
#        opoo fail_lab; opoo verify_jupyter;
#      end
#    end
#
#    jupyter_sys  = `which jupyter`.chomp
#    begin
#      jupyterlabFormula = Formula["jupyterlab"]
#      jupyter_brew = `which #{jupyterlabFormula.opt_bin}/jupyter`.chomp
#    rescue FormulaOrCaskUnavailableError
#      jupyter_brew = ""
#    end
#
#    if !jupyter_sys.empty?
#      ohai found_jupyter+jupyter_sys
#      install_nbextension(jupyter_sys)
#    else
#      if !jupyter_brew.empty?
#        ohai found_jupyter+jupyter_brew
#        install_nbextension(jupyter_brew)
#      else
#        opoo fail_jupyter; opoo install_jupyter;
#      end
#    end
#  end

  def caveats
    <<~EOS
      This package installs the backend extension and tries to install and activate
      the frontend extension via Jupyter. If you don't have Jupyter or your Jupyter
      installation is old / broken / in a non-standard path, you have to install
      and activate the frontend extension yourself.
      On a recent enough version of Jupyter, it should be enough to do:
        
        # For Classic Notebook
        pip install widgetsnbextension
        jupyter nbextension install --py widgetsnbextension
        jupyter nbextension enable --py widgetsnbextension

        # JupyterLab
        jupyter labextension install @jupyter-widgets/jupyterlab-manager
        
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
