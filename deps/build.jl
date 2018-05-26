using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libarpack"], :Arpack),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaLinearAlgebra/ArpackBuilder/releases/download/v3.5.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/ArpackBuilder.aarch64-linux-gnu.tar.gz", "9bfde6c8a50d181a46954eafa4d30aafc67add1f583a874b02c2d65df1b62fde"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/ArpackBuilder.arm-linux-gnueabihf.tar.gz", "fc480fcd13a2b74a310893c77fb22937094fd17744df152b9c2ed3363565a8f4"),
    Linux(:i686, :glibc) => ("$bin_prefix/ArpackBuilder.i686-linux-gnu.tar.gz", "f4b6fd80aa6a57750bfe7b67ace5201feb5888c9b7c8de1710d8b50c27b1b997"),
    Windows(:i686) => ("$bin_prefix/ArpackBuilder.i686-w64-mingw32.tar.gz", "125bcd8f68fe7a49e6c673c748756a514044deb28952d323533ed2267c569959"),
    MacOS(:x86_64) => ("$bin_prefix/ArpackBuilder.x86_64-apple-darwin14.tar.gz", "c4705e089680a405d3751a4741c5ea06739e7ecb0da73f9e7bb06cff0287ad79"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/ArpackBuilder.x86_64-linux-gnu.tar.gz", "65e0c34779550dfd35ab6f9f64ff3e57949dfa5db04d30e960decac49ff91216"),
    Windows(:x86_64) => ("$bin_prefix/ArpackBuilder.x86_64-w64-mingw32.tar.gz", "4f3b84b88a8e1bb78dc12edcc9b8b5f46bca7ef8cfa65f9511d6f715edf4cb05"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
