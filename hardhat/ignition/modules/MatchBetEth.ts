import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MatchBetEth", (m) => {
    const matchBetEth = m.contract("MatchBetEth", []);

    return { matchBetEth };
});
