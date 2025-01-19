from setuptools import setup
from Cython.Build import cythonize

setup(
    name="Milkifier",
    ext_modules=cythonize("MilkUP.pyx", compiler_directives={'language_level': "3"}),
    zip_safe=False,
)