# Notes

LaTeX first class notes collection.

## Build

Build docker image.

```sh
docker build -t latex .
```

```sh
docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t latex .
```

## Run

Start latex docker image.

```sh
docker run -it --rm -v "$(pwd):/app" --name maths latex
```

## Python Environment

Use python environment for generating graph and experiments. Requires `venv`.

```sh
python3 -m venv .venv
```

Activate it by using the script inside the .venv `directory`.

```sh
.venv/Script/activate.sh
```

Install packages from the `requirements.txt`

```sh
pip install -r requirements.txt
```

## Resources

  - Inner product space - <https://en.wikipedia.org/wiki/Inner_product_space>
  - Tensor - <https://en.wikipedia.org/wiki/Tensor>
  - Lissajous curve - <https://en.wikipedia.org/wiki/Lissajous_curve>
