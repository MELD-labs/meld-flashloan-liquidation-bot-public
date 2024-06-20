import sys
import requests
from web3 import Web3
import json
import os
from dotenv import load_dotenv

from web3.middleware import geth_poa_middleware

BASEDIR = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(BASEDIR, '../.env'))

ABI_FOLDER_PATH = "./abis"
RPC = os.getenv('BOT_RPC')
ADDRESS_PROVIDER_CONTRACT_ADDRESS = os.getenv('BOT_ADDRESS_PROVIDER_CONTRACT_ADDRESS')

LIQUIDATOR_WALLET_ADDRESS = os.getenv('BOT_OPERATING_WALLET_ADDRESS')
LIQUIDATOR_WALLET_PRIVATE_KEY = os.getenv('BOT_OPERATING_WALLET_PRIVATE_KEY')

API_URL = os.getenv('BOT_API_URL')

f = open(f'{ABI_FOLDER_PATH}/addressProviderABI.json')
addressProviderABI=json.load(f)
f.close()

f = open(f'{ABI_FOLDER_PATH}/lendingPoolABI.json')
lendingPoolABI=json.load(f)
f.close()

f = open(f'{ABI_FOLDER_PATH}/dataProviderABI.json')
dataProviderABI=json.load(f)
f.close()

f = open(f'{ABI_FOLDER_PATH}/genericABI.json')
genericABI=json.load(f)
f.close()

f = open(f'{ABI_FOLDER_PATH}/liquidateLoanABI.json')
liquidateLoanABI=json.load(f)
f.close()

w3 = Web3(Web3.HTTPProvider(RPC))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

# Get contract addresses
url = f"{API_URL}/v1/lending/global"
response = requests.get(url)

if response.status_code == 200:
    data = response.json()
    ADDRESS_PROVIDER_CONTRACT_ADDRESS = data['addresses']['lendingAddressesProvider']
else:
    # Request failed
    print("Failed to fetch global data")
    print(response.json())
    # exit
    sys.exit()

addressProviderContract = w3.eth.contract(address=Web3.to_checksum_address(ADDRESS_PROVIDER_CONTRACT_ADDRESS), abi=addressProviderABI)

lendingPoolContractAddress = addressProviderContract.functions.getLendingPool().call()
dataProviderContractAddress = addressProviderContract.functions.getProtocolDataProvider().call()

lendingPoolContract = w3.eth.contract(address=Web3.to_checksum_address(lendingPoolContractAddress), abi=lendingPoolABI)
dataProviderContract = w3.eth.contract(address=Web3.to_checksum_address(dataProviderContractAddress), abi=dataProviderABI)

liquidationLoanContract = w3.eth.contract(address=Web3.to_checksum_address(os.getenv('LIQUIDATION_CONTRACT_ADDRESS')), abi=liquidateLoanABI)

print("===================== STARTING LIQUIDATION BOT ============================")
print("============= CONFIG PARAMETERS ==============")
print("Using RPC: ", RPC)
print("Address provider: ", ADDRESS_PROVIDER_CONTRACT_ADDRESS)
print("Lending Pool Address: ", lendingPoolContractAddress)
print("Data Provider Address: ", dataProviderContractAddress)
print("Using bot deployed at address: ", os.getenv('LIQUIDATION_CONTRACT_ADDRESS'))
print("=========== END CONFIG PARAMETERS ============")

CHAIN_ID = w3.eth.chain_id

# Convenience class for debugging
class UserAccountData:
    def __init__(self, blockchainArray):
        self.suppliedAmount = blockchainArray[0]
        self.borrowedAmount = blockchainArray[1]
        self.availableToBorrow = blockchainArray[2]
        self.currentLiquidationThreshold = blockchainArray[3]
        self.ltv = blockchainArray[4]
        self.healthFactor = blockchainArray[5]

    def __str__(self):
        return (f"Supplied (USD): {self.suppliedAmount/pow(10,18)}\n"
        f"Borrowed (USD): {self.borrowedAmount/pow(10,18)}\n"
        f"Available to borrow (USD): {self.availableToBorrow/pow(10,18)}\n"
        f"Current liquidation threshold: {self.currentLiquidationThreshold/100}%\n"
        f"LTV: {self.ltv/100}%\n"
        f"Health factor: {self.healthFactor/pow(10,18)}"
        )



def getUserAccountData(userAddress):
    return lendingPoolContract.functions.getUserAccountData(userAddress).call()


def getLiquidatablePositions():
    url = f"{API_URL}/v1/lending/user/liquidatable"
    response = requests.get(url)
    liquidatablePositions = []
    
    if response.status_code == 200:
        data = response.json()


        for liquidatablePositionData in data:
            liquidatablePositions.append(LiquidatablePosition(liquidatablePositionData))
    else:
        # Request failed
        print("Failed to make REQUEST to get liquidatable positions")
        print(response.json())
        # exit
        sys.exit()

    return liquidatablePositions



class LiquidatablePosition:
    def __init__(self, data):
        self.address = data['address']
        self.riskFactor = data['riskFactor']
        self.borrowedAssets = []
        for borrowedAsset in data['borrowedAssets']:
            self.borrowedAssets.append(
                BorrowedAsset(
                    contract=borrowedAsset['contract'],
                    liquidationPrice=borrowedAsset['liquidationPrice'],
                    stableRate=borrowedAsset['stable'],
                    variableRate=borrowedAsset['variable']
                )
            )
        self.supliedAssets = []
        for supliedAsset in data['supliedAssets']:
            self.supliedAssets.append(
                SuppliedAsset(
                    contract = supliedAsset['contract'],
                    fiatAmount = supliedAsset['fiatAmount'],
                    isCollateral = supliedAsset['isCollateral'],
                    liquidationPrice = supliedAsset['liquidationPrice'],
                    originalSuppliedAmount = supliedAsset['originalSuppliedAmount'],
                    totalSuppliedAmount = supliedAsset['totalSuppliedAmount']
                )
            )

    def __str__(self):
        borrowed_assets_str = "\n".join([str(asset) for asset in self.borrowedAssets])
        supplied_assets_str = "\n".join([str(asset) for asset in self.supliedAssets])
        return f"Address: {self.address}\n\nRisk Factor: {self.riskFactor}\n\nBorrowed Assets:\n{borrowed_assets_str}\n\nSupplied Assets:\n{supplied_assets_str}\n---------------------------------------------------------------"
    

class BorrowedAsset:
    def __init__(self, contract, liquidationPrice, stableRate, variableRate):
        self.contract = contract
        self.liquidationPrice = liquidationPrice
        self.stableRate = StableRate(
            fiatAmount = stableRate['fiatAmount'], 
            originalBorrowedAmount = stableRate['originalBorrowedAmount'], 
            rate = stableRate['rate'], 
            totalBorrowedAmount = stableRate['totalBorrowedAmount']
        )
        self.variableRate = VariableRate (
            fiatAmount = variableRate['fiatAmount'], 
            originalBorrowedAmount = variableRate['originalBorrowedAmount'], 
            totalBorrowedAmount = variableRate['totalBorrowedAmount']
        )
        
    def __str__(self):
        return f"\tContract: {self.contract}\n\tLiquidation Price: {self.liquidationPrice}\n\tStable Rate: {self.stableRate}\n\tVariable Rate: {self.variableRate}"

class SuppliedAsset:
    def __init__(self, contract, fiatAmount, isCollateral, liquidationPrice, originalSuppliedAmount, totalSuppliedAmount):
        self.contract = contract
        self.fiatAmount = fiatAmount
        self.isCollateral = isCollateral
        self.liquidationPrice = liquidationPrice
        self.originalSuppliedAmount = originalSuppliedAmount
        self.totalSuppliedAmount = totalSuppliedAmount
        
    def __str__(self):
        return f"\tContract: {self.contract}\n\tFiat Amount: {self.fiatAmount}\n\tIs Collateral: {self.isCollateral}\n\tLiquidation Price: {self.liquidationPrice}\n\tOriginal Supplied Amount: {self.originalSuppliedAmount}\n\tTotal Supplied Amount: {self.totalSuppliedAmount}\n"

class StableRate:
    def __init__(self, fiatAmount, originalBorrowedAmount, rate, totalBorrowedAmount):
        self.fiatAmount = fiatAmount
        self.originalBorrowedAmount = originalBorrowedAmount
        self.rate = rate
        self.totalBorrowedAmount = totalBorrowedAmount

    def __str__(self):
        return f"\n\t\tFiat Amount: {self.fiatAmount}\n\t\tOriginal Borrowed Amount: {self.originalBorrowedAmount}\n\t\tRate: {self.rate}\n\t\tTotal Borrowed Amount: {self.totalBorrowedAmount}"

class VariableRate: 
    def __init__(self, fiatAmount, originalBorrowedAmount, totalBorrowedAmount):
        self.fiatAmount = fiatAmount
        self.originalBorrowedAmount = originalBorrowedAmount
        self.totalBorrowedAmount = totalBorrowedAmount

    def __str__(self):
        return f"\t\tFiat Amount: {self.fiatAmount}\n\t\tOriginal Borrowed Amount: {self.originalBorrowedAmount}\n\t\tTotal Borrowed Amount: {self.totalBorrowedAmount}"


def liquidate(collateralAddress, debtAddress, pk, caller, walletToLiquidateAddress, debtToCover):
    print(f"Liquidating user: {walletToLiquidateAddress}")
    print(f"Collateral: {collateralAddress}")
    print(f"Debt: {debtAddress}")
    print(f"Debt to cover: {debtToCover}")

    transaction = liquidationLoanContract.functions.liquidateUserWithFlashLoan(
            Web3.to_checksum_address(debtAddress),
            debtToCover,
            Web3.to_checksum_address(collateralAddress), 
            Web3.to_checksum_address(walletToLiquidateAddress),
            [Web3.to_checksum_address(collateralAddress), Web3.to_checksum_address(debtAddress)],
        ).build_transaction({
            'chainId': CHAIN_ID,
            'from': caller,
            'nonce': w3.eth.get_transaction_count(caller),
        })
    signed_txn = w3.eth.account.sign_transaction(transaction, private_key=pk)
    tx_hash = w3.to_hex(w3.keccak(signed_txn.rawTransaction))
    w3.eth.send_raw_transaction(signed_txn.rawTransaction)
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    print(f"TX hash: {receipt['transactionHash'].hex()}")


def trigger_logic():
    liquidatablePositions = getLiquidatablePositions()

    if len(liquidatablePositions) == 0:
        print("=================== NO LIQUIDATIONS DETECTED ==============================")
        sys.exit()
    
    print(f"{len(liquidatablePositions)} positions open to liquidation")
    for liquidatablePosition in liquidatablePositions:

        print("=================== NEW LIQUIDATION DETECTED ==============================")

        # Filter only the liquidatablePosition that isCollateral is true
        liquidatablePosition.supliedAssets = [asset for asset in liquidatablePosition.supliedAssets if asset.isCollateral == True]
        # iterate over the different collaterals to liquidate
        done = False
        for c in liquidatablePosition.supliedAssets:
            print("=================== NEW LIQUIDATION DETECTED ==============================")

            print("collateral: \n", c)

            if float(c.fiatAmount) < 1:
                # If the collateral is less than 1 USD, we skip it
                print("Collateral is less than 1 USD. Skipping")
                continue
            if done:
                # If we already liquidated a position, we break the loop
                break

            for b in liquidatablePosition.borrowedAssets:
                # iterate over the different debts to repay
                print("debt: \n", b)
                
                collateralAddress = Web3.to_checksum_address(c.contract)
                debtAddress = Web3.to_checksum_address(b.contract)

                print(f"Collateral fiat amount: {c.fiatAmount}")
                print(f"Debt fiat amount: {b.variableRate.fiatAmount}")

                liquidationProtocolFee = lendingPoolContract.functions.liquidationProtocolFeePercentage().call() / 100
                print(f"Liquidation protocol fee: {liquidationProtocolFee}%")

                liquidationBonus = dataProviderContract.functions.getReserveConfigurationData(collateralAddress).call()[3] / 100 - 100
                print(f"Liquidation bonus: {liquidationBonus}")

                liquidationScaleFactor = 1 + liquidationBonus * (1 + liquidationProtocolFee / 100) / 100
                print(f"Liquidation scale factor: {liquidationScaleFactor}")


                if (float(b.variableRate.fiatAmount) * liquidationScaleFactor) < float(c.fiatAmount):
                    print("Scaled Debt is less than collateral. We can liquidate full debt")
                    debtToCover = int(b.variableRate.totalBorrowedAmount)
                else:
                    print("Scaled Debt is more than collateral. We can only liquidate the USD-equivalent of the collateral in debt tokens")

                    dDecimals = w3.eth.contract(address=Web3.to_checksum_address(debtAddress), abi=genericABI).functions.decimals().call()
                    oneDebtInUSD = float(b.variableRate.fiatAmount) / float(int(b.variableRate.totalBorrowedAmount) / pow(10, dDecimals))
                    print(f"One debt token in USD: {oneDebtInUSD}")

                    cDecimals = w3.eth.contract(address=Web3.to_checksum_address(collateralAddress), abi=genericABI).functions.decimals().call()
                    oneCollateralInUSD = float(c.fiatAmount) / float(int(c.totalSuppliedAmount) / pow(10, cDecimals))
                    print(f"One collateral token in USD: {oneCollateralInUSD}")

                    # debt To cover is the equivalent amount of debt tokens of the amount of collateral in USD
                    debtToCover = float(c.fiatAmount) / oneDebtInUSD / liquidationScaleFactor

                    print(f"Debt to cover in tokens: {debtToCover}")

                    # Apply a bit of margin to the debt to cover
                    margin = 1.01

                    debtToCover = int (int(debtToCover * pow(10, dDecimals)) * margin)

                    print(f"debtToCover sent to contract: {debtToCover}")

                try:
                    liquidate(
                        collateralAddress = collateralAddress, 
                        debtAddress = debtAddress,
                        pk = LIQUIDATOR_WALLET_PRIVATE_KEY, 
                        caller = LIQUIDATOR_WALLET_ADDRESS,
                        walletToLiquidateAddress = liquidatablePosition.address,
                        debtToCover = debtToCover,
                    )
                    print(f"Succesfully liquidated user: {liquidatablePosition.address}")
                    # finish for loop
                    done = True
                    break
                except Exception as e:
                    print("!!!!!! Failed to liquidate user !!!!!!")
                    print(e.message)

    print("=================== FINISHED LIQUIDATION PROCESS ==========================")



if __name__ == "__main__":
    trigger_logic()

