// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

interface ISwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function fee() external view returns (uint8);

    function feeTo() external view returns (address);

    function getFeeTo() external view returns (address);

    function creator() external view returns (address);

    function birthday() external view returns (uint256);

    function rootKmul() external view returns (uint8);

    function initialize(address, address) external;

    function setFeeTo(address) external;

    function setrootKmul(uint8) external;

    function setFee(uint8) external;
}

interface ISwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function pairCodeHash() external pure returns (bytes32);
}

/**
 * @title Swap库合约
 */
library SwapLibrary {
    using SafeMath for uint256;

    /**
     * @dev 排序token地址
     * @notice 返回排序的令牌地址，用于处理按此顺序排序的对中的返回值
     * @param tokenA TokenA
     * @param tokenB TokenB
     * @return token0  Token0
     * @return token1  Token1
     */
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        //确认tokenA不等于tokenB
        require(tokenA != tokenB, "SwapLibrary: IDENTICAL_ADDRESSES");
        //排序token地址
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        //确认token地址不等于0地址
        require(token0 != address(0), "SwapLibrary: ZERO_ADDRESS");
    }

    /**
     * @dev 获取pair合约地址
     * @notice 计算一对的CREATE2地址，而无需进行任何外部调用
     * @param factory 工厂地址
     * @param tokenA TokenA
     * @param tokenB TokenB
     * @return pair  pair合约地址
     */
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        //排序token地址
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        // 获取pairCodeHash
        bytes32 pairCodeHash = ISwapFactory(factory).pairCodeHash();
        //根据排序的token地址计算create2的pair地址
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        pairCodeHash // init code hash
                    )
                )
            )
        );
    }

    /**
     * @dev 获取储备量
     * @notice 提取并排序一对的储备金
     * @param factory 工厂地址
     * @param tokenA TokenA
     * @param tokenB TokenB
     * @return reserveA  储备量A
     * @return reserveB  储备量B
     * @return fee  手续费
     */
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    )
        internal
        view
        returns (
            uint256 reserveA,
            uint256 reserveB,
            uint8 fee
        )
    {
        //排序token地址
        (address token0, ) = sortTokens(tokenA, tokenB);
        //通过排序后的token地址和工厂合约地址获取到pair合约地址,并从pair合约中获取储备量0,1
        (uint256 reserve0, uint256 reserve1, ) =
            ISwapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        //根据输入的token顺序返回储备量
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        //获取配对合约中设置的手续费比例
        fee = ISwapPair(pairFor(factory, tokenA, tokenB)).fee();
    }

    /**
     * @dev 对价计算
     * @notice 给定一定数量的资产和货币对储备金，则返回等值的其他资产
     * @param amountA 数额A
     * @param reserveA 储备量A
     * @param reserveB 储备量B
     * @return amountB  数额B
     */
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        //确认数额A>0
        require(amountA > 0, "SwapLibrary: INSUFFICIENT_AMOUNT");
        //确认储备量A,B大于0
        require(
            reserveA > 0 && reserveB > 0,
            "SwapLibrary: INSUFFICIENT_LIQUIDITY"
        );
        //数额B = 数额A * 储备量B / 储备量A
        amountB = amountA.mul(reserveB) / reserveA;
    }

    /**
     * @dev 获取单个输出数额
     * @notice 给定一项资产的输入量和配对的储备，返回另一项资产的最大输出量
     * @param amountIn 输入数额
     * @param reserveIn 储备量In
     * @param reserveOut 储备量Out
     * @param fee 手续费比例
     * @return amountOut  输出数额
     */
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint8 fee
    ) internal pure returns (uint256 amountOut) {
        //确认输入数额大于0
        require(amountIn > 0, "SwapLibrary: INSUFFICIENT_INPUT_AMOUNT");
        //确认储备量In和储备量Out大于0
        require(
            reserveIn > 0 && reserveOut > 0,
            "SwapLibrary: INSUFFICIENT_LIQUIDITY"
        );
        //税后输入数额 = 输入数额 * (1000-fee)
        uint256 amountInWithFee = amountIn.mul(1000 - fee);
        //分子 = 税后输入数额 * 储备量Out
        uint256 numerator = amountInWithFee.mul(reserveOut);
        //分母 = 储备量In * 1000 + 税后输入数额
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        //输出数额 = 分子 / 分母
        amountOut = numerator / denominator;
    }

    /**
     * @dev 获取单个输出数额
     * @notice 给定一项资产的输出量和对储备，返回其他资产的所需输入量
     * @param amountOut 输出数额
     * @param reserveIn 储备量In
     * @param reserveOut 储备量Out
     * @param fee 手续费比例
     * @return amountIn  输入数额
     */
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint8 fee
    ) internal pure returns (uint256 amountIn) {
        //确认输出数额大于0
        require(amountOut > 0, "SwapLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        //确认储备量In和储备量Out大于0
        require(
            reserveIn > 0 && reserveOut > 0,
            "SwapLibrary: INSUFFICIENT_LIQUIDITY"
        );
        //分子 = 储备量In * 储备量Out * 1000
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        //分母 = 储备量Out - 输出数额 * (1000-fee)
        uint256 denominator = reserveOut.sub(amountOut).mul(1000 - fee);
        //输入数额 = (分子 / 分母) + 1
        amountIn = (numerator / denominator).add(1);
    }

    /**
     * @dev 获取输出数额
     * @notice 对任意数量的对执行链接的getAmountOut计算
     * @param factory 工厂合约地址
     * @param amountIn 输入数额
     * @param path 路径数组
     * @return amounts  数额数组
     */
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        //确认路径数组长度大于2
        require(path.length >= 2, "SwapLibrary: INVALID_PATH");
        //初始化数额数组
        amounts = new uint256[](path.length);
        //数额数组[0] = 输入数额
        amounts[0] = amountIn;
        //遍历路径数组,path长度-1
        for (uint256 i; i < path.length - 1; i++) {
            //(储备量In,储备量Out,手续费比例) = 获取储备(当前路径地址,下一个路径地址)
            (uint256 reserveIn, uint256 reserveOut, uint8 fee) =
                getReserves(factory, path[i], path[i + 1]);
            //下一个数额 = 获取输出数额(当前数额,储备量In,储备量Out)
            amounts[i + 1] = getAmountOut(
                amounts[i],
                reserveIn,
                reserveOut,
                fee
            );
        }
    }

    /**
     * @dev 获取输出数额
     * @notice 对任意数量的对执行链接的getAmountIn计算
     * @param factory 工厂合约地址
     * @param amountOut 输出数额
     * @param path 路径数组
     * @return amounts  数额数组
     */
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        //确认路径数组长度大于2
        require(path.length >= 2, "SwapLibrary: INVALID_PATH");
        //初始化数额数组
        amounts = new uint256[](path.length);
        //数额数组最后一个元素 = 输出数额
        amounts[amounts.length - 1] = amountOut;
        //从倒数第二个元素倒叙遍历路径数组
        for (uint256 i = path.length - 1; i > 0; i--) {
            //(储备量In,储备量Out,手续费比例) = 获取储备(上一个路径地址,当前路径地址)
            (uint256 reserveIn, uint256 reserveOut, uint8 fee) =
                getReserves(factory, path[i - 1], path[i]);
            //上一个数额 = 获取输入数额(当前数额,储备量In,储备量Out)
            amounts[i - 1] = getAmountIn(
                amounts[i],
                reserveIn,
                reserveOut,
                fee
            );
        }
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

interface ISwapRouter {
    function factory() external view returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint8 fee
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint8 fee
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IERC20Swap {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

/**
 * @title Swap 路由合约
 */
contract SwapRouter is ISwapRouter {
    using SafeMath for uint256;

    /// @notice 布署时定义的常量factory地址和WETH地址
    address public immutable override factory;
    address public immutable override WETH;

    /**
     * @dev 修饰符:确保最后期限大于当前时间
     */
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "SwapRouter: EXPIRED");
        _;
    }

    /**
     * @dev 构造函数
     * @param _factory 工厂合约地址
     * @param _WETH WETH合约地址
     */
    constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
    }

    /**
     * @dev 收款方法
     */
    receive() external payable {
        //断言调用者为WETH合约地址
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** 添加流动性 ****
    /**
     * @dev 添加流动性的私有方法
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param amountADesired 期望数量A
     * @param amountBDesired 期望数量B
     * @param amountAMin 最小数量A
     * @param amountBMin 最小数量B
     * @return amountA   数量A
     * @return amountB   数量B
     */
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        //如果工厂合约不存在,则创建配对
        if (ISwapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            ISwapFactory(factory).createPair(tokenA, tokenB);
        }
        //获取不含虚流动性的储备量reserve{A,B}
        (uint256 reserveA, uint256 reserveB, ) =
            SwapLibrary.getReserves(factory, tokenA, tokenB);
        //如果储备reserve{A,B}==0
        if (reserveA == 0 && reserveB == 0) {
            //数量amount{A,B} = 期望数量A,B
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            //最优数量B = 期望数量A * 储备B / 储备A
            uint256 amountBOptimal =
                SwapLibrary.quote(amountADesired, reserveA, reserveB);
            //如果最优数量B <= 期望数量B
            if (amountBOptimal <= amountBDesired) {
                //确认最优数量B >= 最小数量B
                require(
                    amountBOptimal >= amountBMin,
                    "SwapRouter: INSUFFICIENT_B_AMOUNT"
                );
                //数量amount{A,B} = 期望数量A, 最优数量B
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                //最优数量A = 期望数量A * 储备A / 储备B
                uint256 amountAOptimal =
                    SwapLibrary.quote(amountBDesired, reserveB, reserveA);
                //断言最优数量A <= 期望数量A
                assert(amountAOptimal <= amountADesired);
                //确认最优数量A >= 最小数量A
                require(
                    amountAOptimal >= amountAMin,
                    "SwapRouter: INSUFFICIENT_A_AMOUNT"
                );
                //数量amount{A,B} = 最优数量A, 期望数量B
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    /**
     * @dev 添加流动性方法*
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param amountADesired 期望数量A
     * @param amountBDesired 期望数量B
     * @param amountAMin 最小数量A
     * @param amountBMin 最小数量B
     * @param to to地址
     * @param deadline 最后期限
     * @return amountA   数量A
     * @return amountB   数量B
     * @return liquidity   流动性数量
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        //添加流动性,获取数量A,数量B
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        //根据TokenA,TokenB地址,获取`pair合约`地址
        address pair = SwapLibrary.pairFor(factory, tokenA, tokenB);
        //将数量为amountA的tokenA从msg.sender账户中安全发送到pair合约地址
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        //将数量为amountB的tokenB从msg.sender账户中安全发送到pair合约地址
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        //流动性数量 = pair合约的铸造方法铸造给to地址的返回值
        liquidity = ISwapPair(pair).mint(to);
    }

    /**
     * @dev 添加ETH流动性方法*
     * @param token token地址
     * @param amountTokenDesired Token期望数量
     * @param amountTokenMin Token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @return amountToken   Token数量
     * @return amountETH   ETH数量
     * @return liquidity   流动性数量
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        //添加流动性,获取Token数量,ETH数量
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        //根据Token,WETH地址,获取`pair合约`地址
        address pair = SwapLibrary.pairFor(factory, token, WETH);
        //将`Token数量`的token从msg.sender账户中安全发送到`pair合约`地址
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        //向`ETH合约`存款`ETH数量`的主币
        IWETH(WETH).deposit{value: amountETH}();
        //将`ETH数量`的`ETH`token发送到`pair合约`地址
        assert(IWETH(WETH).transfer(pair, amountETH));
        //流动性数量 = pair合约的铸造方法铸造给`to地址`的返回值
        liquidity = ISwapPair(pair).mint(to);
        //如果`收到的主币数量`>`ETH数量` 则返还`收到的主币数量`-`ETH数量`
        if (msg.value > amountETH)
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** 移除流动性 ****
    /**
     * @dev 移除流动性*
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param liquidity 流动性数量
     * @param amountAMin 最小数量A
     * @param amountBMin 最小数量B
     * @param to to地址
     * @param deadline 最后期限
     * @return amountA   数量A
     * @return amountB   数量B
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        //计算TokenA,TokenB的CREATE2地址，而无需进行任何外部调用
        address pair = SwapLibrary.pairFor(factory, tokenA, tokenB);
        //将流动性数量从用户发送到pair地址(需提前批准)
        ISwapPair(pair).transferFrom(msg.sender, pair, liquidity);
        //pair合约销毁流动性数量,并将数值0,1的token发送到to地址
        (uint256 amount0, uint256 amount1) = ISwapPair(pair).burn(to);
        //排序tokenA,tokenB
        (address token0, ) = SwapLibrary.sortTokens(tokenA, tokenB);
        //按排序后的token顺序返回数值AB
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        //确保数值AB大于最小值AB
        require(amountA >= amountAMin, "SwapRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "SwapRouter: INSUFFICIENT_B_AMOUNT");
    }

    /**
     * @dev 移除ETH流动性*
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @return amountToken   token数量
     * @return amountETH   ETH数量
     */
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH)
    {
        //(token数量,ETH数量) = 移除流动性(token地址,WETH地址,流动性数量,token最小数量,ETH最小数量,当前合约地址,最后期限)
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        //将token数量的token发送到to地址
        TransferHelper.safeTransfer(token, to, amountToken);
        //从WETH取款ETH数量的主币
        IWETH(WETH).withdraw(amountETH);
        //将ETH数量的ETH发送到to地址
        TransferHelper.safeTransferETH(to, amountETH);
    }

    /**
     * @dev 带签名移除流动性*
     * @param tokenA tokenA地址
     * @param tokenB tokenB地址
     * @param liquidity 流动性数量
     * @param amountAMin 最小数量A
     * @param amountBMin 最小数量B
     * @param to to地址
     * @param deadline 最后期限
     * @param approveMax 全部批准
     * @param v v
     * @param r r
     * @param s s
     * @return amountA   数量A
     * @return amountB   数量B
     */
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        //计算TokenA,TokenB的CREATE2地址，而无需进行任何外部调用
        address pair = SwapLibrary.pairFor(factory, tokenA, tokenB);
        //如果全部批准,value值等于最大uint256,否则等于流动性
        uint256 value = approveMax ? uint256(-1) : liquidity;
        //调用pair合约的许可方法(调用账户,当前合约地址,数值,最后期限,v,r,s)
        ISwapPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        //(数量A,数量B) = 移除流动性(tokenA地址,tokenB地址,流动性数量,最小数量A,最小数量B,to地址,最后期限)
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    /**
     * @dev 带签名移除ETH流动性*
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @param approveMax 全部批准
     * @param v v
     * @param r r
     * @param s s
     * @return amountToken   token数量
     * @return amountETH   ETH数量
     */
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        override
        returns (uint256 amountToken, uint256 amountETH)
    {
        //计算Token,WETH的CREATE2地址，而无需进行任何外部调用
        address pair = SwapLibrary.pairFor(factory, token, WETH);
        //如果全部批准,value值等于最大uint256,否则等于流动性
        uint256 value = approveMax ? uint256(-1) : liquidity;
        //调用pair合约的许可方法(调用账户,当前合约地址,数值,最后期限,v,r,s)
        ISwapPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        //(token数量,ETH数量) = 移除ETH流动性(token地址,流动性数量,token最小数量,ETH最小数量,to地址,最后期限)
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    /**
     * @dev 移除流动性支持Token收转帐税*
     * @param token token地址
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @return amountETH   ETH数量
     */
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountETH) {
        //(,ETH数量) = 移除流动性(token地址,WETH地址,流动性数量,token最小数量,ETH最小数量,当前合约地址,最后期限)
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        //将当前合约中的token数量的token发送到to地址
        TransferHelper.safeTransfer(
            token,
            to,
            IERC20(token).balanceOf(address(this))
        );
        //从WETH取款ETH数量的主币
        IWETH(WETH).withdraw(amountETH);
        //将ETH数量的ETH发送到to地址
        TransferHelper.safeTransferETH(to, amountETH);
    }

    /**
     * @dev 带签名移除流动性,支持Token收转帐税*
     * @param token token地址
     * @param liquidity 流动性数量
     * @param liquidity 流动性数量
     * @param amountTokenMin token最小数量
     * @param amountETHMin ETH最小数量
     * @param to to地址
     * @param deadline 最后期限
     * @param approveMax 全部批准
     * @param v v
     * @param r r
     * @param s s
     * @return amountETH   ETH数量
     */
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountETH) {
        //计算Token,WETH的CREATE2地址，而无需进行任何外部调用
        address pair = SwapLibrary.pairFor(factory, token, WETH);
        //如果全部批准,value值等于最大uint256,否则等于流动性
        uint256 value = approveMax ? uint256(-1) : liquidity;
        //调用pair合约的许可方法(调用账户,当前合约地址,数值,最后期限,v,r,s)
        ISwapPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        //(,ETH数量) = 移除流动性支持Token收转帐税(token地址,流动性数量,Token最小数量,ETH最小数量,to地址,最后期限)
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** 交换 ****
    /**
     * @dev 私有交换*
     * @notice 要求初始金额已经发送到第一对
     * @param amounts 数额数组
     * @param path 路径数组
     * @param _to to地址
     */
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        //遍历路径数组
        for (uint256 i; i < path.length - 1; i++) {
            //(输入地址,输出地址) = (当前地址,下一个地址)
            (address input, address output) = (path[i], path[i + 1]);
            //token0 = 排序(输入地址,输出地址)
            (address token0, ) = SwapLibrary.sortTokens(input, output);
            //输出数量 = 数额数组下一个数额
            uint256 amountOut = amounts[i + 1];
            //(输出数额0,输出数额1) = 输入地址==token0 ? (0,输出数额) : (输出数额,0)
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0
                    ? (uint256(0), amountOut)
                    : (amountOut, uint256(0));
            //to地址 = i<路径长度-2 ? (输出地址,路径下下个地址)的pair合约地址 : to地址
            address to =
                i < path.length - 2
                    ? SwapLibrary.pairFor(factory, output, path[i + 2])
                    : _to;
            //调用(输入地址,输出地址)的pair合约地址的交换方法(输出数额0,输出数额1,to地址,0x00)
            ISwapPair(SwapLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    /**
     * @dev 根据精确的token交换尽量多的token*
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts  数额数组
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        //数额数组 ≈ 遍历路径数组(
        //      (输入数额 * (1000-fee) * 储备量Out) /
        //      (储备量In * 1000 + 输入数额 * (1000-fee)))
        amounts = SwapLibrary.getAmountsOut(factory, amountIn, path);
        //确认数额数组最后一个元素>=最小输出数额
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        //将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        //私有交换(数额数组,路径数组,to地址)
        _swap(amounts, path, to);
    }

    /**
     * @dev 使用尽量少的token交换精确的token*
     * @param amountOut 精确输出数额
     * @param amountInMax 最大输入数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts  数额数组
     */
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        //数额数组 ≈ 遍历路径数组(
        //      (储备量In * 储备量Out * 1000) /
        //      (储备量Out - 输出数额 * (1000-fee)) + 1)
        amounts = SwapLibrary.getAmountsIn(factory, amountOut, path);
        //确认数额数组第一个元素<=最大输入数额
        require(
            amounts[0] <= amountInMax,
            "SwapRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        //将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        //私有交换(数额数组,路径数组,to地址)
        _swap(amounts, path, to);
    }

    /**
     * @dev 根据精确的ETH交换尽量多的token*
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts  数额数组
     */
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        //确认路径第一个地址为WETH
        require(path[0] == WETH, "SwapRouter: INVALID_PATH");
        //数额数组 ≈ 遍历路径数组(
        //      (msg.value * (1000-fee) * 储备量Out) /
        //      (储备量In * 1000 + msg.value * (1000-fee)))
        amounts = SwapLibrary.getAmountsOut(factory, msg.value, path);
        //确认数额数组最后一个元素>=最小输出数额
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        //将数额数组[0]的数额存款ETH到ETH合约
        IWETH(WETH).deposit{value: amounts[0]}();
        //断言将数额数组[0]的数额的ETH发送到路径(0,1)的pair合约地址
        assert(
            IWETH(WETH).transfer(
                SwapLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        //私有交换(数额数组,路径数组,to地址)
        _swap(amounts, path, to);
    }

    /**
     * @dev 使用尽量少的token交换精确的ETH*
     * @param amountOut 精确输出数额
     * @param amountInMax 最大输入数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts  数额数组
     */
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        //确认路径最后一个地址为WETH
        require(path[path.length - 1] == WETH, "SwapRouter: INVALID_PATH");
        //数额数组 ≈ 遍历路径数组(
        //      (储备量In * 储备量Out * 1000) /
        //      (储备量Out - 输出数额 * (1000-fee)) + 1)
        amounts = SwapLibrary.getAmountsIn(factory, amountOut, path);
        //确认数额数组第一个元素<=最大输入数额
        require(
            amounts[0] <= amountInMax,
            "SwapRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        //将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        //私有交换(数额数组,路径数组,当前合约地址)
        _swap(amounts, path, address(this));
        //从ETH合约提款数额数组最后一个数值的ETH
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        //将数额数组最后一个数值的ETH发送到to地址
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    /**
     * @dev 根据精确的token交换尽量多的ETH*
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts  数额数组
     */
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        //确认路径最后一个地址为WETH
        require(path[path.length - 1] == WETH, "SwapRouter: INVALID_PATH");
        //数额数组 ≈ 遍历路径数组(
        //      (输入数额 * (1000-fee) * 储备量Out) /
        //      (储备量In * 1000 + 输入数额 * (1000-fee))))
        amounts = SwapLibrary.getAmountsOut(factory, amountIn, path);
        //确认数额数组最后一个元素>=最小输出数额
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        //将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SwapLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        //私有交换(数额数组,路径数组,当前合约地址)
        _swap(amounts, path, address(this));
        //从WETH合约提款数额数组最后一个数值的ETH
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        //将数额数组最后一个数值的ETH发送到to地址
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    /**
     * @dev 使用尽量少的ETH交换精确的token*
     * @param amountOut 精确输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     * @return amounts  数额数组
     */
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        //确认路径第一个地址为WETH
        require(path[0] == WETH, "SwapRouter: INVALID_PATH");
        //数额数组 ≈ 遍历路径数组(
        //      (储备量In * 储备量Out * 1000) /
        //      (储备量Out - 输出数额 * (1000-fee)) + 1)
        amounts = SwapLibrary.getAmountsIn(factory, amountOut, path);
        //确认数额数组第一个元素<=msg.value
        require(amounts[0] <= msg.value, "SwapRouter: EXCESSIVE_INPUT_AMOUNT");
        //将数额数组[0]的数额存款ETH到WETH合约
        IWETH(WETH).deposit{value: amounts[0]}();
        //断言将数额数组[0]的数额的WETH发送到路径(0,1)的pair合约地址
        assert(
            IWETH(WETH).transfer(
                SwapLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        //私有交换(数额数组,路径数组,to地址)
        _swap(amounts, path, to);
        //如果`收到的主币数量`>`数额数组[0]` 则返还`收到的主币数量`-`数额数组[0]`
        if (msg.value > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** 交换 (支持收取转帐税的Token) ****
    // requires the initial amount to have already been sent to the first pair
    /**
     * @dev 私有交换支持Token收转帐税*
     * @param path 路径数组
     * @param _to to地址
     */
    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address _to
    ) internal virtual {
        //遍历路径数组
        for (uint256 i; i < path.length - 1; i++) {
            //(输入地址,输出地址) = (当前地址,下一个地址)
            (address input, address output) = (path[i], path[i + 1]);
            // 根据输入地址,输出地址找到配对合约
            ISwapPair pair =
                ISwapPair(SwapLibrary.pairFor(factory, input, output));
            //token0 = 排序(输入地址,输出地址)
            (address token0, ) = SwapLibrary.sortTokens(input, output);
            // 定义一些数额变量
            uint256 amountInput;
            uint256 amountOutput;
            {
                //避免堆栈太深的错误
                //获取配对的交易手续费
                uint8 fee = pair.fee();
                //获取配对合约的储备量0,储备量1
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                // 排序输入储备量和输出储备量
                (uint256 reserveInput, uint256 reserveOutput) =
                    input == token0
                        ? (reserve0, reserve1)
                        : (reserve1, reserve0);
                // 储备量0,1,配对合约中的余额-储备量
                amountInput = IERC20(input).balanceOf(address(pair)).sub(
                    reserveInput
                );
                //根据输入数额,输入储备量,输出储备量,交易手续费计算输出数额
                amountOutput = SwapLibrary.getAmountOut(
                    amountInput,
                    reserveInput,
                    reserveOutput,
                    fee
                );
            }
            // // 排序输出数额0,输出数额1
            (uint256 amount0Out, uint256 amount1Out) =
                input == token0
                    ? (uint256(0), amountOutput)
                    : (amountOutput, uint256(0));
            //to地址 = i<路径长度-2 ? (输出地址,路径下下个地址)的pair合约地址 : to地址
            address to =
                i < path.length - 2
                    ? SwapLibrary.pairFor(factory, output, path[i + 2])
                    : _to;
            //调用pair合约的交换方法(输出数额0,输出数额1,to地址,0x00)
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    /**
     * @dev 根据精确的token交换尽量多的token,支持Token收转帐税*
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     */
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        //将数量为数额数组[0]的路径[0]的token从调用者账户发送到路径0,1的pair合约
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SwapLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        // 记录to地址在地址路径最后一个token中的余额
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        // 调用私有交换支持Token收转帐税方法
        _swapSupportingFeeOnTransferTokens(path, to);
        // 确认to地址收到的地址路径中最后一个token数量大于最小输出数量
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >=
                amountOutMin,
            "SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    /**
     * @dev 根据精确的ETH交换尽量多的token,支持Token收转帐税*
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     */
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        //确认路径第一个地址为WETH
        require(path[0] == WETH, "SwapRouter: INVALID_PATH");
        //输入数量=合约收到的主币数量
        uint256 amountIn = msg.value;
        //向WETH合约存款ETH
        IWETH(WETH).deposit{value: amountIn}();
        //断言将WETH发送到了地址路径0,1组成的配对合约中
        assert(
            IWETH(WETH).transfer(
                SwapLibrary.pairFor(factory, path[0], path[1]),
                amountIn
            )
        );
        // 记录to地址在地址路径最后一个token中的余额
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        // 调用私有交换支持Token收转帐税方法
        _swapSupportingFeeOnTransferTokens(path, to);
        // 确认to地址收到的地址路径中最后一个token数量大于最小输出数量
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >=
                amountOutMin,
            "SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    /**
     * @dev 根据精确的token交换尽量多的ETH,支持Token收转帐税*
     * @param amountIn 精确输入数额
     * @param amountOutMin 最小输出数额
     * @param path 路径数组
     * @param to to地址
     * @param deadline 最后期限
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        //确认路径最后一个地址为WETH
        require(path[path.length - 1] == WETH, "SwapRouter: INVALID_PATH");
        //将地址路径0的Token发送到地址路径0,1组成的配对合约
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            SwapLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        //调用私有交换支持Token收转帐税方法
        _swapSupportingFeeOnTransferTokens(path, address(this));
        //输出金额=当前合约收到的WETH数量
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        //确认输出金额大于最小输出数额
        require(
            amountOut >= amountOutMin,
            "SwapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        //向WETH合约取款
        IWETH(WETH).withdraw(amountOut);
        //将ETH发送到to地址
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return SwapLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint8 fee
    ) public pure virtual override returns (uint256 amountOut) {
        return SwapLibrary.getAmountOut(amountIn, reserveIn, reserveOut, fee);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut,
        uint8 fee
    ) public pure virtual override returns (uint256 amountIn) {
        return SwapLibrary.getAmountIn(amountOut, reserveIn, reserveOut, fee);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return SwapLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return SwapLibrary.getAmountsIn(factory, amountOut, path);
    }
}
