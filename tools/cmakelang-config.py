# -----------------------------
# Options affecting formatting.
# -----------------------------
with section("format"):
    line_width = 120

# ----------------------------
# Options affecting the linter
# ----------------------------
with section("lint"):
    # regular expression pattern describing valid function names
    function_pattern = '[0-9a-z_]+'

    # regular expression pattern describing valid names for privatedirectory
    # variables
    # ign-cmake customization: accept private variables that don't start with _
    # accept mix of uppercase/lowercase
    # TODO(jrivero): change all private variable to start with _ in new major
    # version ign-cmake3
    private_var_pattern = '_?[0-9A-Za-z_]+'

    # regular expression pattern describing valid macro names
    # ign-cmake customization: accept lower case chars
    macro_pattern = '[0-9A-Za-z_]+'
