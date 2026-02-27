import os
from setuptools import setup


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


setup(
    name="pipeline1",
    version="1.0.0",
    author="Nicholas Etuk",
    author_email="nick_etuk@hotmail.com",
    description=("Runs a collection of scripts in a in sequence"),
    license="",
    keywords="pipeline setup",
    url="http://asterlan.com",
    # packages=find_packages(","),
    packages=['pipeline1'],
    long_description=read("README.md"),
    classifiers=[],
)
