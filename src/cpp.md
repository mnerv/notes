# C++ Code Snippet

Contain code snippet for C++ gathered over the years.

## Type safe length of C array

```cpp
template <typename T, std::size_t N>
constexpr auto length_of(T (&)[N]) -> std::size_t {
    return N;
}
```

This code is equivalent to making a macro to get the length of C style array.

```cpp
#define length_of(x) sizeof(x) / sizeof(x[0])
```

Usage:

```cpp
std::int32_t arr[] = {1, 2, 3, 4};

length_of(arr);  // 4
```

## Curry function with Template

This template function is trying to emulate the curry technique of converting a
function that takes multiple arguments into a sequence of functions that each
takes a single argument.

[Currying - Wikipedia](https://en.wikipedia.org/wiki/Currying).

```cpp
template <typename callable, typename... params>
auto curry(callable f, params... ps) {
    if constexpr (requires { f(ps...); }) {
        return f(ps...);
    } else {
        return [f, ps...](auto... qs) {
            return curry(f, ps..., qs...);
        };
    }
}
```

Usage:

```cpp
auto fn = [](std::int32_t a, std::int32_t b) {
    return a + b;
};

auto crr = curry(fn, 1);
crr(2);  // 3
```

## Read text into std::string

This will read the whole text file into memory which is not ideal if the file is
really large.

```cpp
#include <fstream>
#include <ios>
```

```cpp
auto read_text(std::string const& filename) -> std::string {
    std::ifstream input{filename, std::ios::in};
    if (!input.is_open() || input.fail())
        throw std::runtime_error("ERROR: Loading textfile!");
    return {
        std::istreambuf_iterator<char>(input),
        std::istreambuf_iterator<char>()
    };
}
```

## Compile time array precompute values

This uses lambda to precompute values for a fixed array at compile time. Requires `C++17`.

```cpp
static constexpr auto axis = [] {
    std::array<double, num_points> a{};
    for (int i = 0; i < num_points; ++i) {
        a[i] = static_cast<double>(i);
    }
    return a;
}();
```

Source: [stackoverflow](https://stackoverflow.com/questions/56383454/initialize-an-stdarray-algorithmically-at-compile-time)

