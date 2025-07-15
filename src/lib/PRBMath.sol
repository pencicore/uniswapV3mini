// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/// @title PRBMath
/// @author Paul Razvan Berg
/// @notice Smart contract library for advanced fixed-point math that works with uint256 and int256.

library PRBMath {
    /// @notice The maximum value an uint256 number can have.
    uint256 internal constant MAX_UINT256 =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /// @notice The maximum value an int256 number can have.
    int256 internal constant MAX_INT256 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /// @notice The minimum value an int256 number can have.
    int256 internal constant MIN_INT256 = -0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - 1;

    /// @notice The scaling factor used for fixed-point numbers: 1e18.
    uint256 internal constant SCALE = 1e18;

    /// @notice The half scale, used for rounding.
    uint256 internal constant HALF_SCALE = 5e17;

    /// @notice Calculates floor(a × b ÷ denominator) with full precision.
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product

            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256.
            require(denominator > prod1, "PRBMath: overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, lpotdod)
                prod0 := div(prod0, lpotdod)
                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            // Shift in bits from prod1 into prod0
            prod0 |= prod1 * lpotdod;

            // Invert the denominator mod 2^256
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            result = prod0 * inverse;
            return result;
        }
    }

    /// @notice Calculates floor(x * y / SCALE) with full precision.
    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {
        result = mulDiv(x, y, SCALE);
    }

    /// @notice Rounds x to the nearest integer. If the fractional part is 0.5 or more, it rounds up.
    function round(uint256 x) internal pure returns (uint256 result) {
        result = (x + HALF_SCALE) / SCALE;
    }
}
