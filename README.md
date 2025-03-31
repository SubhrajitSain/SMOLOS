# SMOLOS

A dumb little OS made in x86 16-bit Assembly (and very little C).

## Description

SMOLOS is a simple operating system project written primarily in x86 16-bit assembly language. It's designed for educational purposes, demonstrating fundamental OS concepts and low-level programming techniques.

## Contribution Required

This project is actively seeking contributors! It needs help with:

* **Building a proper kernel:** Help to build a proper kernel with a prompt.
* **Adding new commands:** Expand the OS's functionality by adding commands to the kernel. *Commands required: clear, help, echo, add, sub, mul, div, exec, read (more on that later below)*
* **Developing drivers:** Implement support for various hardware like keyboard and screen.
* **Creating a file manager:** Enable file storage and retrieval.
* **Testing and debugging:** Help identify and fix bugs.

If you have experience with x86-64 assembly, operating system development, or low-level programming, I encourage you to contribute!

**How to Contribute:**

1.  **Fork the repository.**
2.  **Create a new branch** for your feature or bug fix.
3.  **Make your changes** and commit them with proper descriptive commit messages.
4.  **Push your changes** to your fork.
5.  **Submit a pull request** to the main repository.

*Include a link to your Github account as credit.*

Please ensure your code adheres to the project's coding style and includes appropriate comments to mark your changes.

**Reporting Issues:**

If you encounter any issues or have suggestions for improvements, please open an issue on the GitHub repository.

**Code Style:**

* Use clear and descriptive variable and function names.
* Add comments to explain every operation.
* Follow consistent indentation and formatting.
* Do not modify code that you are unsure of before asking.


## Build Process

To build and run SMOLOS, follow these steps:

1.  **Clean the `build` directory:**

    ```bash
    make clean
    ```

2.  **Build the OS image:**

    ```bash
    make
    ```

    This will assemble the assembly code and create a floppy disk image (`build/main_floppy.img`).

3.  **Run SMOLOS in QEMU:**

    ```bash
    qemu-system-x86_64 -fda build/main_floppy.img
    ```

    This command will launch QEMU and boot the OS from the generated floppy disk image.

## Prerequisites

* `nasm` (Netwide Assembler)
* `make`
* `qemu-system-x86_64`
* Check the `Makefile` for other prerequisites.

## Licensing

This project is licensed under the **MIT License**. See the `LICENSE` file for more information.
