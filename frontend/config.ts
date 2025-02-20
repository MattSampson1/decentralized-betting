import { getDefaultConfig } from "connectkit";
import { createConfig } from "wagmi";
import { mainnet, polygon, optimism, arbitrum, baseSepolia } from "wagmi/chains";

export const config = createConfig(
    getDefaultConfig({
        appName: "Lockbox Sports",
        chains: [baseSepolia, mainnet, polygon, optimism, arbitrum],
        walletConnectProjectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
    })
);

declare module "wagmi" {
    interface Register {
        config: typeof config;
    }
}
