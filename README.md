Interesting stuff from writing a metal kernel

Profiling it is trivial just run Command+I in Xcode

Writing a kernel is very similar to CUDA, they're async by default and need synchronization

Some terminology that's different
* Compute Pipeline State: Defines the GPU's execution state and the compute shader code to run.
* Command Buffer: Holds a sequence of commands (encoded using encoders) that the GPU will execute.
* Compute Command Encoder: Records compute commands into the command buffer, specifying the compute pipeline state and how to execute it (e.g., resources to use and the number of threads).
