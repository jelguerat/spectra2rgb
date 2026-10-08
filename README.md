# spectra2rgb

<!-- badges: start -->
<!-- badges: end -->

Convert hyperspectral reflectance signatures to sRGB hex codes and
CIE L*a*b* colour coordinates, using the CIE 1931 2-degree standard
observer and the D65 standard illuminant.

Developed for leaf-level plant phenotyping data from the PSI PlantScreen
platform, but applicable to any reflectance spectra in the 400-700 nm
range.

## Installation

```r
# install.packages("devtools")
devtools::install_github("yourname/spectra2rgb")
```

## Quick start

```r
library(spectra2rgb)

# A single spectrum
wl  <- seq(400, 700, by = 10)
ref <- 0.1 + 0.6 * exp(-((wl - 550) / 60)^2)   # synthetic green peak

hs_to_xyz(wl, ref)         # CIE XYZ tristimulus values
xyz_to_rgb(hs_to_xyz(wl, ref))  # sRGB (0-255 + hex)
```

## Data-frame workflow

```r
library(spectra2rgb)

# df: rows = samples, columns = wavelengths (nm), named numerically
set.seed(1)
wl  <- seq(400, 700, by = 10)
mat <- matrix(runif(5 * length(wl), 0.1, 0.9), nrow = 5)
colnames(mat) <- as.character(wl)
df  <- as.data.frame(mat)

# Convert to sRGB + CIELAB in one call
spectra_to_rgb_lab(df, id_col = paste0("leaf_", 1:5))
```

## Missing values

Three policies via `na_action`:

- `"zero"` (default) — replace non-finite reflectance with 0
- `"drop"` — remove all-NA rows with a warning
- `"keep"` — preserve NA in the output for downstream filtering

```r
df2 <- df; df2[2, ] <- NA

spectra_to_rgb(df2, na_action = "zero")   # silent
spectra_to_rgb(df2, na_action = "drop")   # warns, removes row
spectra_to_rgb(df2, na_action = "keep")   # keeps NA
```

## Functions

| Function | Purpose |
|---|---|
| `hs_to_xyz(wavelengths, reflectance)` | Reflectance -> CIE XYZ |
| `xyz_to_rgb(XYZ)` | CIE XYZ -> sRGB (0-255 + hex) |
| `rgb_to_lab(R, G, B)` | sRGB -> CIELAB |
| `xyz_to_lab(XYZ)` | CIE XYZ -> CIELAB |
| `spectra_to_rgb(df, id_col)` | Data frame of spectra -> sRGB |
| `spectra_to_lab(df, id_col)` | Data frame of spectra -> CIELAB |
| `spectra_to_rgb_lab(df, id_col)` | Data frame -> both |

## Method

Reflectance spectra are integrated against the CIE 1931 2-degree
standard observer and the D65 standard illuminant to obtain CIE XYZ
tristimulus values. XYZ is transformed to linear sRGB via the IEC
61966-2-1 matrix, gamma-encoded, and quantised to 8-bit RGB. CIELAB
coordinates are computed from sRGB using the D65 white point
(Xn = 95.047, Yn = 100.000, Zn = 108.883).

Wavelengths outside the CIE CMF range are extrapolated flat; for
visible-colour applications the standard 400-700 nm range is
recommended.

## Citation

If you use `spectra2rgb` in published work, please cite:

> Elguera, J. (2026). spectra2rgb: Convert spectral signatures to
> sRGB and CIELAB colour coordinates. R package version 0.1.0.

## License

MIT (see LICENSE).
