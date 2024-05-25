import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "./tasks/functionsSimulate.js"

const config: HardhatUserConfig = {
    solidity: "0.8.24",
    networks: {
        hardhat: {},
    },
};

export default config;
