use ethers_core::{types::H160, utils::to_checksum};
use hex::FromHex;
use rustler::NifStruct;
use siwe::eip4361::{Message, Version};
use std::str::FromStr;

#[derive(NifStruct)]
#[module = "Siwe"]
pub struct Parsed {
    pub domain: String,
    pub address: String,
    pub statement: String,
    pub uri: String,
    pub version: String,
    pub chain_id: String,
    pub nonce: String,
    pub issued_at: String,
    pub expiration_time: Option<String>,
    pub not_before: Option<String>,
    pub request_id: Option<String>,
    pub resources: Vec<String>,
}

fn version_string(v: Version) -> String {
    match v {
        Version::V1 => "1".to_string(),
    }
}

#[rustler::nif]
fn verify(message: String, sig: String) -> Parsed {
    // TODO: Replace Unwraps w/ Result.
    let s = <[u8; 65]>::from_hex(sig.chars().skip(2).collect::<String>()).unwrap();
    match Message::from_str(&message) {
        Err(e) => panic!("{}", e),
        Ok(m) => match m.verify_eip191(s) {
            Ok(_) => Parsed {
                domain: m.domain.to_string(),
                address: to_checksum(&H160(m.address.into()), None),
                statement: m.statement,
                uri: m.uri.to_string(),
                version: version_string(m.version),
                chain_id: m.chain_id,
                nonce: m.nonce,
                issued_at: m.issued_at,
                expiration_time: m.expiration_time,
                not_before: m.not_before,
                request_id: m.request_id,
                resources: m.resources.into_iter().map(|s| s.to_string()).collect(),
            },
            Err(e) => panic!("{}", e),
        },
    }
}

rustler::init!("Elixir.Siwe", [verify]);
