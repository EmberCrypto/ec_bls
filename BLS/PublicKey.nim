#BLS Objects.
import Objects

#String utils standard lib.
import strutils

{.push, header: "bls.hpp".}

#Constructors.
proc publicKeyFromPrivateKey(
    key: PrivateKeyObject
): PublicKeyObject {.importcpp: "#.GetPublicKey()".}

proc publicKeyFromBytes(
    bytes: ptr uint8
): PublicKeyObject {.importcpp: "bls::PublicKey::FromBytes(@)".}

#Equality operators
proc `==`(
    lhs: PublicKeyObject,
    rhs: PublicKeyObject
): bool {.importcpp: "# == #"}

proc `!=`(
    lhs: PublicKeyObject,
    rhs: PublicKeyObject
): bool {.importcpp: "# != #"}

#Serialize.
proc serialize(
    key: PublicKeyObject,
    buffer: ptr uint8
) {.importcpp: "#.Serialize(@)".}

{.pop.}

#Constructors.
proc getPublicKey*(key: PrivateKey): PublicKey =
    #Allocate the Public Key.
    result.data = PublicKeyRef()
    #Create the Public Key.
    result.data[] = publicKeyFromPrivateKey(key.data[])

proc newPublicKeyFromBytes*(keyArg: string): PublicKey =
    #Allocate the Public Key.
    result.data = PublicKeyRef()

    #If a binary string was passed in...
    if keyArg.len == 48:
        #Extract the argument.
        var key: string = keyArg
        #Create the Public Key.
        result.data[] = publicKeyFromBytes(cast[ptr uint8](addr key[0]))

    #If a hex string was passed in...
    elif keyArg.len == 96:
        #Define a array for the key.
        var key: array[48, uint8]
        #Parse the hex string.
        for b in countup(0, 95, 2):
            key[b div 2] = uint8(parseHexInt(keyArg[b .. b + 1]))
        #Create the Public Key.
        result.data[] = publicKeyFromBytes(addr key[0])

    #Else, throw an error.
    else:
        raise newException(ValueError, "Invalid BLS Public Key length.")

#Equality operators.
proc `==`*(lhs: PublicKey, rhs: PublicKey): bool =
    lhs.data[] == rhs.data[]

proc `!=`*(lhs: PublicKey, rhs: PublicKey): bool =
    lhs.data[] != rhs.data[]

#Assignment operator.
proc `=`*(lhs: var PublicKey, rhs: PublicKey) =
    lhs.data[] = rhs.data[]

#Stringify a Public Key.
proc toString*(key: PublicKey): string =
    #Create the result string.
    result = newString(48)
    #Serialize the key into the string.
    key.data[].serialize(cast[ptr uint8](addr result[0]))

#Stringify a Public Key for printing.
proc `$`*(key: PublicKey): string =
    #Create the result string.
    result = ""

    #Get the binary version of the string.
    var serialized: string = key.toString()

    #Format the serialized string into a hex string.
    for i in serialized:
        result &= uint8(i).toHex()