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
```
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

