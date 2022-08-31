import { ConnectButton } from "web3uikit"
import { useMoralis } from "react-moralis"
import { useEffect } from "react"

export default function Header() {
    // const { enableWeb3, account, isWeb3Enabled } = useMoralis()
    // useEffect(() => {
    //   console.log("Hi", isWeb3Enabled);
    // }, [isWeb3Enabled])

    return (
        <div className="p-5 border-b-2 flex flex-row">
            <h1 className="py-4 px-4 font-blog text-3xl">Decentralized Lottery</h1>
            <div className="ml-auto py-2 px-4">
                <ConnectButton moralisAuth={false} />
            </div>

            {/* {account ? `connected with ${account.slice(0, 6)}...` : "not connected"} */}
        </div>
    )
}
