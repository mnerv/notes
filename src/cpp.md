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

source: [stackoverflow](https://stackoverflow.com/questions/56383454/initialize-an-stdarray-algorithmically-at-compile-time)

## Simple 32-bit unicode to utf8 conversion

This code is only used for learning purpose only, it is simple enough to know what unicode is and what is utf8.

```cpp
// Test with C++17, C++20
#include <array>
#include <cstdint>

constexpr std::size_t UTF8_SIZE = 4;  // byte
constexpr auto code2utf8(std::uint32_t const& code) -> std::array<std::uint8_t, UTF8_SIZE> {
    // Leading sequence for different byte size
    constexpr std::uint8_t LEAD_1BYTE = 0b00000000;  // 0x00
    constexpr std::uint8_t LEAD_2BYTE = 0b11000000;  // 0xC0
    constexpr std::uint8_t LEAD_3BYTE = 0b11100000;  // 0xE0
    constexpr std::uint8_t LEAD_4BYTE = 0b11110000;  // 0xF0
    constexpr std::uint8_t LEAD_REST  = 0b10000000;  // 0x80

    // Max character count for different byte size
    // Use for selecting utf8 byte size for the current code
    constexpr std::uint32_t MAX_CHAR_1BYTE = 0x0000007F;  // MAX 127     CHARACTERS WITH 1 BYTE
    constexpr std::uint32_t MAX_CHAR_2BYTE = 0x00000800;  // MAX 2048    CHARACTERS WITH 2 BYTE
    constexpr std::uint32_t MAX_CHAR_3BYTE = 0x00010000;  // MAX 65536   CHARACTERS WITH 3 BYTE
    constexpr std::uint32_t MAX_CHAR_4BYTE = 0x00200000;  // MAX 2097152 CHARACTERS WITH 4 BYTE

    // Filter out trash data in the code for different
    // byte size of the utf8.
    constexpr std::uint8_t FILTER_1BYTE    = 0b01111111;
    constexpr std::uint8_t FILTER_2BYTE    = 0b00011111;
    constexpr std::uint8_t FILTER_3BYTE    = 0b00001111;
    constexpr std::uint8_t FILTER_4BYTE    = 0b00000111;
    constexpr std::uint8_t FILTER_REST     = 0b00111111;

    // Initialise the element with zero
    std::array<std::uint8_t, UTF8_SIZE> codes{0x00};

    // The LEAD pattern determines what size utf8 it is and the rest of the
    // code have a leading 1. This is the reason utf8 only supports
    // maximum 127 character with one byte.
    if (code <= MAX_CHAR_1BYTE) {
        codes[3] = LEAD_1BYTE | (FILTER_1BYTE & code);
    } else if (code <= MAX_CHAR_2BYTE) {
        codes[2] = LEAD_2BYTE | (FILTER_2BYTE & (code >> 6));
        codes[3] = LEAD_REST  | (FILTER_REST  & (code >> 0));
    } else if (code <= MAX_CHAR_3BYTE) {
        codes[1] = LEAD_3BYTE | (FILTER_3BYTE & (code >> 12));
        codes[2] = LEAD_REST  | (FILTER_REST  & (code >> 6));
        codes[3] = LEAD_REST  | (FILTER_REST  & (code >> 0));
    } else if (code <= MAX_CHAR_4BYTE) {
        codes[0] = LEAD_4BYTE | (FILTER_4BYTE & (code >> 18));
        codes[1] = LEAD_REST  | (FILTER_REST  & (code >> 12));
        codes[2] = LEAD_REST  | (FILTER_REST  & (code >> 6));
        codes[3] = LEAD_REST  | (FILTER_REST  & (code >> 0));
    }

    return codes;
}
```

This is only something I've wrote to learn about `unicode` and `utf8`.

by: [mnerv](https://github.com/mnerv)

## std::random

```cpp
#include <random>
// ...

std::random_device rdevice;
std::mt19937 rng{rdevice()};
std::uniform_int_distribution<std::mt19937::result_type> dist(0, 1);
```

