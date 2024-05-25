/** @type {import('next').NextConfig} */
export default {
    webpack: (config) => {
        config.resolve.fallback = { fs: false, net: false, tls: false };
        return config;
    },
};
