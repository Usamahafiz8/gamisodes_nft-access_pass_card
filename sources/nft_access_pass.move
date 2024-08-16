module nft_access_pass::nft_access_pass {
  
  use sui::url::{Self, Url};
  use std::string;
  
  // A simple NFT that can be minted by anyone
  public struct NFT has key, store {
    id: UID,                            // unique id of the NFT
    name: string::String,               // name of the NFT
    description: string::String,        // description of the NFT
    url: Url,                           // url of the NFT image
    creator: address,                   // creator of the NFT
    attributes: vector<string::String>, // custom attributes
  }

  // Create and mint a new NFT
  public entry fun mint(
    name: vector<u8>, 
    description: vector<u8>, 
    url: vector<u8>, 
    attributes: vector<vector<u8>>, // Attributes as a vector of bytes
    ctx: &mut TxContext
  ) {
    // Convert attributes from vector of bytes to vector of strings
    let mut attr_strings = vector::empty<string::String>(); // Declare as mutable
    let length = vector::length(&attributes);
    let mut i = 0;
    while (i < length) {
      let attr = vector::borrow(&attributes, i);
      let attr_string = string::utf8(*attr);
      vector::push_back(&mut attr_strings, attr_string); // Push to mutable vector
      i = i + 1;
    };
    
    // create the new NFT
    let nft = NFT {
      id: object::new(ctx),
      name: string::utf8(name),
      description: string::utf8(description),
      url: url::new_unsafe_from_bytes(url),
      creator: tx_context::sender(ctx),
      attributes: attr_strings,
    };
    
    // mint and send the NFT to the caller
    let sender = tx_context::sender(ctx);
    transfer::public_transfer(nft, sender);
  }

  /// Transfer an existing NFT to another address
  public entry fun transfer(
    nft: NFT, 
    recipient: address
  ) {
    // Transfer the NFT to the specified recipient
    transfer::public_transfer(nft, recipient);
  }
}
