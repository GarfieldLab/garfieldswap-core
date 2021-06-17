// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface ISwapCallee {
    function swapCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
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

contract SwapERC20 is IERC20Swap {
    using SafeMath for uint256;

    /// @notice token名称
    string public constant override name = "Garfield Swap LP Token";
    /// @notice token缩写
    string public override symbol = "GLP";
    /// @notice 精度
    uint8 public constant override decimals = 18;
    /// @notice 总量
    uint256 public override totalSupply;
    /// @notice 余额映射
    mapping(address => uint256) public override balanceOf;
    /// @notice 批准映射
    mapping(address => mapping(address => uint256)) public override allowance;

    /// @notice 域分割
    bytes32 public override DOMAIN_SEPARATOR;
    /// @notice The EIP-712 typehash for the contract's domain
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant override PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    /// @notice nonces映射
    mapping(address => uint256) public override nonces;

    /// @notice 批准事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    /// @notice 发送事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev 构造函数
     */
    constructor() public {
        // 链ID
        uint256 chainId;
        // 获取链ID
        // solium-disable-next-line
        assembly {
            chainId := chainid()
        }
        //EIP712Domain
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, "Swap: EXPIRED");
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "Swap: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

/**
 * @title 交易钩子合约接口
 */
interface ISwapHook {
    function swapHook(
        address sender,
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external;
}

/**
 * @title Swap 配对合约
 */
contract SwapPair is SwapERC20 {
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    /// @notice 最小流动性 = 1000
    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    /// @dev transfer的selector编码
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    /// @notice 工厂合约地址
    address public factory;
    /// @dev token地址数组
    address public token0;
    address public token1;

    /// @notice 收税地址
    address public feeTo; // feeTo
    /// @notice 配对创建者
    address public creator; // creator
    /// @notice 交易钩子合约地址
    address public swapHookAddress;

    /// @dev token储备量
    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    /// @dev 更新储备量的最后时间戳
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    /// @notice 配对合约创建时间
    uint256 public birthday;
    /// @dev token价格最后累计
    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    /// @notice 在最近一次流动性事件之后的K值,储备量0*储备量1，自最近一次流动性事件发生后
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event
    /// @notice 流动性相当于sqrt（k）增长的1/6
    uint8 public rootKmul = 5; // mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    /// @notice 手续费占比0.3%
    uint8 public fee = 3; // 0.3%

    /// @dev 防止重入开关
    uint256 private unlocked = 1;

    /**
     * @dev 事件:铸造
     * @param sender 发送者
     * @param amount0 输入金额0
     * @param amount1 输入金额1
     */
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    /**
     * @dev 事件:销毁
     * @param sender 发送者
     * @param amount0 输入金额0
     * @param amount1 输入金额1
     * @param to to地址
     */
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    /**
     * @dev 事件:交换
     * @param sender 发送者
     * @param amount0In 输入金额0
     * @param amount1In 输入金额1
     * @param amount0Out 输出金额0
     * @param amount1Out 输出金额1
     * @param to to地址
     */
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    /**
     * @dev 事件:同步
     * @param reserve0 储备量0
     * @param reserve1 储备量1
     */
    event Sync(uint112 reserve0, uint112 reserve1);

    /**
     * @dev 事件:收税地址更新
     * @param feeTo 收税地址
     */
    event FeeToUpdated(address indexed feeTo);

    /**
     * @dev 事件:K值乘数更新
     * @param rootKmul K值乘数
     */
    event RootKmulUpdated(uint8 rootKmul);

    /**
     * @dev 事件:交易钩子合约地址更新
     * @param swapHookAddress 交易钩子合约地址
     */
    event SwapHookUpdated(address swapHookAddress);

    /**
     * @dev 事件:收税比例更新
     * @param fee 收税比例
     */
    event FeeUpdated(uint8 fee);

    /**
     * @dev 修饰符:锁定运行防止重入
     */
    modifier lock() {
        require(unlocked == 1, "Swap: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    /**
     * @dev 修饰符:确认必须为工厂合约的FeeToSetter地址
     */
    modifier onlyFeeToSetter() {
        // 确认必须为工厂合约的FeeToSetter地址
        require(
            msg.sender == ISwapFactory(factory).feeToSetter(),
            "Swap: FORBIDDEN"
        );
        _;
    }

    /**
     * @dev 获取储备
     * @return _reserve0 储备量0
     * @return _reserve1 储备量1
     * @return _blockTimestampLast 时间戳
     */
    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    /**
     * @dev 私有安全发送
     * @param token token
     * @param to    to地址
     * @param value 数额
     */
    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "UniswapV2: TRANSFER_FAILED"
        );
    }

    /**
     * @dev 构造函数
     */
    constructor() public {
        //factory地址为合约布署者
        factory = msg.sender;
        birthday = block.timestamp;
    }

    /**
     * @dev 初始化方法,部署时由工厂调用一次
     * @param _token0 token0
     * @param _token1 token1
     */
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "Swap: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
        symbol = string(
            abi.encodePacked(
                "GLP:",
                IERC20Swap(_token0).symbol(),
                "-",
                IERC20Swap(_token1).symbol()
            )
        );
    }

    /**
     * @dev 设置收税地址
     * @param _feeTo 收税地址
     */
    function setFeeTo(address _feeTo) external onlyFeeToSetter {
        feeTo = _feeTo;
        emit FeeToUpdated(_feeTo);
    }

    /**
     * @dev 设置K值乘数
     * @param _rootKmul K值乘数
     */
    function setRootKmul(uint8 _rootKmul) external onlyFeeToSetter {
        rootKmul = _rootKmul;
        emit RootKmulUpdated(_rootKmul);
    }

    /**
     * @dev 设置收税比例
     * @param _fee 收税比例
     */
    function setFee(uint8 _fee) external onlyFeeToSetter {
        fee = _fee;
        emit FeeUpdated(fee);
    }

    /**
     * @dev 设置交易钩子合约地址
     * @param _swapHookAddress 交易钩子合约地址
     */
    function setSwapHook(address _swapHookAddress) external onlyFeeToSetter {
        swapHookAddress = _swapHookAddress;
        emit SwapHookUpdated(swapHookAddress);
    }

    /**
     * @dev 获取收税地址
     * @return 收税地址
     */
    function getFeeTo() public view returns (address) {
        // 如果feeTo地址不为0地址,以feeTo地址为准
        if (feeTo != address(0)) {
            return feeTo;
            // 否则如果配对合约创建30天之后,以工程合约的feeTo地址为准
        } else if (block.timestamp.sub(birthday) > 30 days) {
            return ISwapFactory(factory).feeTo();
            // 否者feeTo地址为配对合约创建者
        } else {
            return creator;
        }
    }

    /**
     * @dev 更新储量，并在每个区块的第一次调用时更新价格累加器
     * @param balance0 余额0
     * @param balance1  余额1
     * @param _reserve0 储备0
     * @param _reserve1 储备1
     */
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        //确认余额0和余额1小于等于最大的uint112
        require(
            balance0 <= uint112(-1) && balance1 <= uint112(-1),
            "Swap: OVERFLOW"
        );
        //区块时间戳,将时间戳转换为uint32
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        //计算时间流逝
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        //如果时间流逝>0 并且 储备量0,1不等于0
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            //价格0最后累计 += 储备量1 * 2**112 / 储备量0 * 时间流逝
            price0CumulativeLast +=
                uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            //价格1最后累计 += 储备量0 * 2**112 / 储备量1 * 时间流逝
            price1CumulativeLast +=
                uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }
        //余额0,1放入储备量0,1
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        //更新最后时间戳
        blockTimestampLast = blockTimestamp;
        //触发同步事件
        emit Sync(reserve0, reserve1);
    }

    /**
     * @dev 默认情况下铸造流动性相当于1/6的增长sqrt（k）
     * @param _reserve0 储备0
     * @param _reserve1 储备1
     */
    function _mintFee(uint112 _reserve0, uint112 _reserve1)
        private
    {
        //定义k值
        uint256 _kLast = kLast; // gas savings
        //如果k值不等于0
        if (_kLast != 0 && rootKmul > 0) {
            //计算(_reserve0*_reserve1)的平方根
            uint256 rootK = Math.sqrt(uint256(_reserve0).mul(_reserve1));
            //计算k值的平方根
            uint256 rootKLast = Math.sqrt(_kLast);
            //如果rootK>rootKLast
            if (rootK > rootKLast) {
                //分子 = erc20总量 * (rootK - rootKLast)
                uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                //分母 = rootK * 5 + rootKLast
                uint256 denominator = rootK.mul(rootKmul).add(rootKLast);
                //流动性 = 分子 / 分母
                uint256 liquidity = numerator / denominator;
                // 如果流动性 > 0 将流动性铸造给feeTo地址
                if (liquidity > 0) _mint(getFeeTo(), liquidity);
            }
        }
    }

    /**
     * @dev 铸造方法
     * @param to to地址
     * @return liquidity 流动性数量
     * @notice 应该从执行重要安全检查的合同中调用此低级功能
     */
    function mint(address to) external lock returns (uint256 liquidity) {
        //获取`储备量0`,`储备量1`
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        //获取当前合约在token0合约内的余额
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        //获取当前合约在token1合约内的余额
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        //amount0 = 余额0
        uint256 amount0 = balance0.sub(_reserve0);
        //amount1 = 余额1
        uint256 amount1 = balance1.sub(_reserve1);

        //调用铸造费方法
        _mintFee(_reserve0, _reserve1);
        //获取totalSupply,必须在此处定义，因为totalSupply可以在mintFee中更新
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        //如果_totalSupply等于0,首次创建配对
        if (_totalSupply == 0) {
            //流动性 = (数量0 * 数量1)的平方根 - 最小流动性1000
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            //在总量为0的初始状态,永久锁定最低流动性
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens

            // 设置配对创建者为to地址
            creator = to; // set creator
        } else {
            //流动性 = 最小值 (amount0 * _totalSupply / _reserve0) 和 (amount1 * _totalSupply / _reserve1)
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }
        //确认流动性 > 0
        require(liquidity > 0, "Swap: INSUFFICIENT_LIQUIDITY_MINTED");
        //铸造流动性给to地址
        _mint(to, liquidity);

        //更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        //k值 = 储备0 * 储备1,储备量中包含虚流动性,所以要再减去
        kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        //触发铸造事件
        emit Mint(msg.sender, amount0, amount1);
    }

    /**
     * @dev 销毁方法
     * @param to to地址
     * @return amount0
     * @return amount1
     * @notice 应该从执行重要安全检查的合同中调用此低级功能
     */
    function burn(address to)
        external
        lock
        returns (uint256 amount0, uint256 amount1)
    {
        //获取`储备量0`,`储备量1`
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        //获取当前合约在token0合约内的余额
        address _token0 = token0;
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        //获取当前合约在token1合约内的余额
        address _token1 = token1;
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        //从当前合约的balanceOf映射中获取当前合约自身的流动性数量,移除流动性的之前先将lptoken发送到配对合约
        uint256 liquidity = balanceOf[address(this)];

        //调用铸造费方法
        _mintFee(_reserve0, _reserve1);
        //获取totalSupply,必须在此处定义，因为totalSupply可以在mintFee中更新
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        //amount0 = 流动性数量 * 余额0 / totalSupply   使用余额确保按比例分配
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        //amount1 = 流动性数量 * 余额1 / totalSupply   使用余额确保按比例分配
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        //确认amount0和amount1都大于0
        require(
            amount0 > 0 && amount1 > 0,
            "Swap: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        //销毁当前合约内的流动性数量
        _burn(address(this), liquidity);
        //将amount0数量的_token0发送给to地址
        _safeTransfer(_token0, to, amount0);
        //将amount1数量的_token1发送给to地址
        _safeTransfer(_token1, to, amount1);
        //更新balance0
        balance0 = IERC20(_token0).balanceOf(address(this));
        //更新balance1
        balance1 = IERC20(_token1).balanceOf(address(this));

        //更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        //k值 = 储备0 * 储备1,储备量中包含虚流动性,所以要再减去
        kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        //触发销毁事件
        emit Burn(msg.sender, amount0, amount1, to);
    }

    /**
     * @dev 交换方法
     * @param amount0Out 输出数额0
     * @param amount1Out 输出数额1
     * @param to    to地址
     * @param data  用于回调的数据
     * @notice 应该从执行重要安全检查的合同中调用此低级功能
     */
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external lock {
        //确认amount0Out和amount1Out都大于0
        require(
            amount0Out > 0 || amount1Out > 0,
            "Swap: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        //获取`储备量0`,`储备量1`
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        //确认`输出数量0,1` < `储备量0,1`
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "Swap: INSUFFICIENT_LIQUIDITY"
        );

        //初始化变量
        uint256 balance0;
        uint256 balance1;
        {
            //标记_token{0,1}的作用域，避免堆栈太深的错误
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            //确认to地址不等于_token0和_token1
            require(to != _token0 && to != _token1, "Swap: INVALID_TO");
            //如果`输出数量0` > 0 安全发送`输出数量0`的token0到to地址
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            //如果`输出数量1` > 0 安全发送`输出数量1`的token1到to地址
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            //如果data的长度大于0 调用to地址的接口,闪电贷!
            if (data.length > 0)
                ISwapCallee(to).swapCall(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                );
            //调用交易钩子
            if (swapHookAddress != address(0))
                ISwapHook(swapHookAddress).swapHook(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    to
                );
            //获取当前合约在token0合约内的余额
            balance0 = IERC20(_token0).balanceOf(address(this));
            //获取当前合约在token1合约内的余额
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        //如果 余额0 > 储备0 - amount0Out 则 amount0In = 余额0 - (储备0 - amount0Out) 否则 amount0In = 0
        uint256 amount0In =
            balance0 > _reserve0 - amount0Out
                ? balance0 - (_reserve0 - amount0Out)
                : 0;
        //如果 余额1 > 储备1 - amount1Out 则 amount1In = 余额1 - (储备1 - amount1Out) 否则 amount1In = 0
        uint256 amount1In =
            balance1 > _reserve1 - amount1Out
                ? balance1 - (_reserve1 - amount1Out)
                : 0;
        //确认`输入数量0||1`大于0
        require(
            amount0In > 0 || amount1In > 0,
            "Swap: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            //标记reserve{0,1}的作用域，避免堆栈太深的错误
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            //调整后的余额0 = 余额0 * 1000 - (amount0In * fee)
            uint256 balance0Adjusted =
                balance0.mul(1000).sub(amount0In.mul(fee));
            //调整后的余额1 = 余额1 * 1000 - (amount1In * fee)
            uint256 balance1Adjusted =
                balance1.mul(1000).sub(amount1In.mul(fee));
            //确认balance0Adjusted * balance1Adjusted >= 储备0 * 储备1 * 1000000
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint256(_reserve0).mul(_reserve1).mul(1000**2),
                "Swap: K"
            );
        }

        //更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        //触发交换事件
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    /**
     * @dev 强制平衡以匹配储备
     * @param to to地址
     */
    function skim(address to) external lock {
        //将当前合约在`token0,1`的余额-`储备量0,1`安全发送到to地址
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)).sub(reserve0)
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)).sub(reserve1)
        );
    }

    /**
     * @dev 强制准备金与余额匹配
     */
    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}

/**
 * @title Swap工厂合约
 */
contract SwapFactory is ISwapFactory {
    /// @notice 收税地址
    address public override feeTo;
    /// @notice 收税权限控制地址,应为治理地址
    address public override feeToSetter;
    /// @notice 配对映射,地址=>(地址=>地址)
    mapping(address => mapping(address => address)) public override getPair;
    /// @notice 所有配对数组
    address[] public override allPairs;

    /**
     * @dev 事件:创建配对
     * @param token0 token0
     * @param token1 token1
     * @param pair 配对地址
     */
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    /**
     * @dev 构造函数
     */
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    /**
     * @dev 查询配对数组长度方法
     */
    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    /**
     * @dev  配对合约源代码Bytecode的hash值(用作前端计算配对合约地址)
     */
    function pairCodeHash() external pure override returns (bytes32) {
        return keccak256(type(SwapPair).creationCode);
    }

    /**
     * @dev 创建配对
     * @param tokenA TokenA
     * @param tokenB TokenB
     * @return pair 配对地址
     * @notice 应该从路由合约调用配对寻找工厂合约来调用,否则通过路由合约找不到配对合约
     */
    function createPair(address tokenA, address tokenB)
        external
        override
        returns (address pair)
    {
        //确认tokenA不等于tokenB
        require(tokenA != tokenB, "Swap: IDENTICAL_ADDRESSES");
        //将tokenA和tokenB进行大小排序,确保tokenA小于tokenB
        (address token0, address token1) =
            tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        //确认token0不等于0地址
        require(token0 != address(0), "Swap: ZERO_ADDRESS");
        //确认配对映射中不存在token0=>token1
        require(getPair[token0][token1] == address(0), "Swap: PAIR_EXISTS"); // single check is sufficient
        //给bytecode变量赋值"SwapPair"合约的创建字节码
        bytes memory bytecode = type(SwapPair).creationCode;
        //将token0和token1打包后创建哈希
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        //内联汇编
        //solium-disable-next-line
        assembly {
            //通过create2方法布署合约,并且加盐,返回地址到pair变量
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        //调用pair地址的合约中的"initialize"方法,传入变量token0,token1
        SwapPair(pair).initialize(token0, token1);
        //配对映射中设置token0=>token1=pair
        getPair[token0][token1] = pair;
        //配对映射中设置token1=>token0=pair
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        //配对数组中推入pair地址
        allPairs.push(pair);
        //触发配对成功事件
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @dev 修饰符:确认必须为工厂合约的FeeToSetter地址
     */
    modifier onlyFeeToSetter() {
        // 确认必须为工厂合约的FeeToSetter地址
        require(msg.sender == feeToSetter, "Swap: FORBIDDEN");
        _;
    }

    /**
     * @dev 设置收税地址
     * @param _feeTo 收税地址
     */
    function setFeeTo(address _feeTo) external override onlyFeeToSetter {
        feeTo = _feeTo;
    }

    /**
     * @dev 设置收税权限控制
     * @param _feeToSetter 收税权限控制
     */
    function setFeeToSetter(address _feeToSetter)
        external
        override
        onlyFeeToSetter
    {
        feeToSetter = _feeToSetter;
    }
}
