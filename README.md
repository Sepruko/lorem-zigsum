# `ziggy-ipsum`

> Lorem ipsum dolor, right? Right?

Just a boring lorem ipsum generator I made, because a friend told me to. It doesn't work perfectly as it doesn't
randomly pick punctuation as well as I'd like it to, but otherwise it is fine.

## Usage

```sh
ipsum <number>
```

### Example

```sh
ipsum 20

# Generates 20 words...

Ercu id magna nullam condimentum vehicula. Eestibulum orci ut ante bibendum laoreet nisl aliquam.

Egestas mauris mattis gravida dui maecenas.
```

## Building

Building `ziggy-ipsum` is pretty easy!

### Requirements

- A Zig compiler, preferably [the first-party one](https://ziglang.org/download).
    - This project targets the `main` branch of Zig, so you should download the latest version
      available.
- A Git-compatible version control system, such as [Git itself](https://git-scm.com/download).
    - As long as it can pull a repository from [GitHub](https://github.com/).

### Steps

1. Clone [this repository](https://github.com/Sepruko/ziggy-ipsum) to your local machine using your
   chosen Git implementation.

    ```sh
    # This example uses the first-party implementation available from the above-linked download page.
    # 
    # This will clone the repository to "ziggy-ipsum" in the current directory, if you would like it
    # elsewhere then supply a second positional parameter of the folder name. 
    git clone https://github.com/Sepruko/ziggy-ipsum.git
    ```

2. `cd` into the newly-cloned directory.

    ```sh
    # If your shell does not support this operation, consider using a different one.
    cd ziggy-ipsum
    ```

3. Compile the program using the Zig compiler you downloaded.

    ```sh
    # This example uses the first-party implementation available from the above-linked download page.
    #
    # You can optionally provide the "-Dstrip" flag to not include debug symbols in the final binary.
    zig build


    # Want to build for all supported targets? This also supports the "-Dstrip" flag.
    zig build all
    ```

4. The first-party Zig compiler will place the built file(s) in `<cloned-repo>/zig-out/bin`. Other
   compilers will likely do the same to keep compatibility, otherwise have fun!

## Licensing

This project is licensed under the MIT license, a copy is provided [here](LICENSE).
