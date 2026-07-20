use std::env;
use std::path::PathBuf;

fn main() {
    let manifest_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let engine_path = PathBuf::from(manifest_dir.as_str()).join("engine");
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());

    let has_nvcc = std::process::Command::new("nvcc")
        .arg("--version")
        .output()
        .is_ok();

    let mut builder = cc::Build::new();
    builder.files([
        engine_path.join("tensor.c").to_str().unwrap(),
        engine_path.join("stream.c").to_str().unwrap(),
        engine_path.join("quant.c").to_str().unwrap(),
        engine_path.join("attention.c").to_str().unwrap(),
        engine_path.join("tokenizer.c").to_str().unwrap(),
        engine_path.join("inference.c").to_str().unwrap(),
        engine_path.join("otter_bridge.c").to_str().unwrap(),
    ]);

    if has_nvcc {
        let cuda_path = PathBuf::from(manifest_dir.as_str()).join("cuda");
        builder.file(cuda_path.join("kernels.cu").to_str().unwrap());
        builder.cuda(true);
        builder.define("USE_CUDA", None);
        println!("cargo:rustc-link-lib=dylib=cudart");
        println!("cargo:rustc-link-search=native=/usr/local/cuda/lib64");
    }

    builder.include(&engine_path)
        .compile("otter_engine");

    println!("cargo:rustc-link-lib=static=otter_engine");
    println!("cargo:rustc-link-lib=m");
    println!("cargo:rerun-if-changed=engine/");
    println!("cargo:rerun-if-changed=cuda/");
}
