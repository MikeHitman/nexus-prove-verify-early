#!/bin/bash

export RED='\033[0;31m'
export NC='\033[0m'

echo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo
source "$HOME/.cargo/env"
echo 
rustc --version
echo
wget https://github.com/Kitware/CMake/releases/download/v3.30.2/cmake-3.30.2.tar.gz
echo
tar xzf cmake-3.30.2.tar.gz
echo
cd cmake-3.30.2/
./configure --help
echo
./configure --prefix=/opt/cmake
echo
make
echo
make install
echo
/opt/cmake/bin/cmake -version
echo
cmake
echo
cmake --version
cd ..
echo
rustup target add riscv32i-unknown-none-elf
echo
cargo install --git https://github.com/nexus-xyz/nexus-zkvm cargo-nexus --tag 'v0.2.1'
echo
cargo nexus --help
echo
cargo nexus new nexus-project
echo
cd nexus-project
echo
cargo nexus run
echo
cargo nexus prove
echo
cargo nexus verify
echo
cd ~
cd /workspaces/codespaces-blank/
cargo nexus host nexus-host
echo
cd nexus-host/src/guest/src/
cat << EOF > main.rs
#![cfg_attr(target_arch = "riscv32", no_std, no_main)]
 
use nexus_rt::{println, read_private_input, write_output};
 
#[nexus_rt::main]
fn main() {
    let input = read_private_input::<(u32, u32)>();
 
    let mut z: i32 = -1;
    if let Ok((x, y)) = input {
        println!("Read private input: ({}, {})", x, y);
 
        z = (x * y) as i32;
    } else {
        println!("No private input provided...");
    }
 
    write_output::<i32>(&z)
}
EOF
echo 
cd ../../
cat << EOF > main.rs
use nexus_sdk::{
    compile::CompileOpts,
    nova::seq::{Generate, Nova, PP},
    Local, Prover, Verifiable,
};
 
type Input = (u32, u32);
type Output = i32;
 
const PACKAGE: &str = "guest";
 
fn main() {
    println!("Setting up Nova public parameters...");
    let pp: PP = PP::generate().expect("failed to generate parameters");
 
    let mut opts = CompileOpts::new(PACKAGE);
    opts.set_memlimit(8); // use an 8mb memory
 
    println!("Compiling guest program...");
    let prover: Nova<Local> = Nova::compile(&opts).expect("failed to compile guest program");
 
    let input: Input = (3, 5);
 
    print!("Proving execution of vm...");
    let proof = prover
        .prove_with_input::<Input>(&pp, &input)
        .expect("failed to prove program");
 
    println!(
        " output is {}!",
        proof
            .output::<Output>()
            .expect("failed to deserialize output")
    );
 
    println!(">>>>> Logging\n{}<<<<<", proof.logs().join("\n"));
 
    print!("Verifying execution...");
    proof.verify(&pp).expect("failed to verify proof");
 
    println!("  Succeeded!");
}
EOF
cargo run -r
echo
echo -e "${RED}Thank you for your participation. Follow me https://x.com/NoworkNoresult ${NC}"
