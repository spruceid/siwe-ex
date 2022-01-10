use ethers_core::{types::H160, utils::to_checksum};
use hex::FromHex;
use http::uri::Authority;
use iri_string::types::UriString;
use rustler::{Error, NifResult, NifStruct};
use siwe::eip4361::{Message, Version};
use std::str::FromStr;
use rand::{thread_rng, Rng};
use rand::distributions::Alphanumeric;

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

impl Parsed {
    pub fn to_eip4361_message(&self) -> NifResult<Message> {
        let mut next_resources: Vec<UriString> = Vec::new();
        for resource in &self.resources {
            let x = UriString::from_str(resource).map_err(|_e| Error::BadArg)?;
            next_resources.push(x);
        }

        Ok(Message {
            domain: Authority::from_str(&self.domain).map_err(|_e| Error::BadArg)?,
            address: <[u8; 20]>::from_hex(self.address.chars().skip(2).collect::<String>())
                .map_err(|_e| Error::BadArg)?,
            statement: self.statement.to_string(),
            uri: UriString::from_str(&self.uri).map_err(|_e| Error::BadArg)?,
            version: Version::from_str(&self.version).map_err(|_e| Error::BadArg)?,
            chain_id: self.chain_id.to_string(),
            nonce: self.nonce.to_string(),
            issued_at: self.issued_at.to_string(),
            expiration_time: self.expiration_time.clone(),
            not_before: self.not_before.clone(),
            request_id: self.request_id.clone(),
            resources: next_resources,
        })
    }
}

fn version_string(v: Version) -> String {
    match v {
        Version::V1 => "1".to_string(),
    }
}

fn message_to_parsed(m: Message) -> Parsed {
    Parsed {
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
    }
}

#[rustler::nif]
fn from_str(message: String) -> NifResult<Parsed> {
    Ok(message_to_parsed(
        Message::from_str(&message).map_err(|_e| Error::BadArg)?,
    ))
}

#[rustler::nif]
fn to_str(message: Parsed) -> NifResult<String> {
    Ok(message
        .to_eip4361_message()
        .map_err(|_e| Error::BadArg)?
        .to_string())
}

#[rustler::nif]
fn validate_sig(message: Parsed, sig: String) -> bool {
    match message.to_eip4361_message() {
        Ok(m) => match <[u8; 65]>::from_hex(sig.chars().skip(2).collect::<String>()) {
            Ok(s) => match m.verify_eip191(&s) {
                Ok(_) => true,
                Err(_) => false,
            },
            Err(_) => false,
        },
        Err(_) => false,
    }
}

#[rustler::nif]
fn validate_time(message: Parsed) -> bool {
    match message.to_eip4361_message() {
        Ok(m) => m.valid_now(),
        Err(_) => false,
    }
}

#[rustler::nif]
fn validate(message: Parsed, sig: String) -> bool {
    match message.to_eip4361_message() {
        Ok(m) => match <[u8; 65]>::from_hex(sig.chars().skip(2).collect::<String>()) {
            Ok(s) => match m.verify_eip191(&s) {
                Ok(_) => m.valid_now(),
                Err(_) => false,
            },
            Err(_) => false,
        },
        Err(_) => false,
    }
}

#[rustler::nif]
fn parse_if_valid_time(message: String) -> NifResult<Parsed> {
    match Message::from_str(&message) {
        Err(_) => Err(Error::BadArg),
        Ok(m) => {
            if m.valid_now() {
                Ok(message_to_parsed(m))
            } else {
                Err(Error::BadArg)
            }
        }
    }
}

#[rustler::nif]
fn parse_if_valid_sig(message: String, sig: String) -> NifResult<Parsed> {
    let s = <[u8; 65]>::from_hex(sig.chars().skip(2).collect::<String>())
        .map_err(|_e| Error::BadArg)?;
    let m = Message::from_str(&message).map_err(|_e| Error::BadArg)?;
    m.verify_eip191(&s).map_err(|_e| Error::BadArg)?;

    Ok(message_to_parsed(m))
}

#[rustler::nif]
fn parse_if_valid(message: String, sig: String) -> NifResult<Parsed> {
    let s = <[u8; 65]>::from_hex(sig.chars().skip(2).collect::<String>())
        .map_err(|_e| Error::BadArg)?;
    match Message::from_str(&message) {
        Err(_) => Err(Error::BadArg),
        Ok(m) => match m.verify_eip191(&s) {
            Ok(_) => {
                if m.valid_now() {
                    Ok(message_to_parsed(m))
                } else {
                    Err(Error::BadArg)
                }
            }

            Err(_) => Err(Error::BadArg),
        },
    }
}

#[rustler::nif]
fn generate_nonce() -> String {
    thread_rng()
    .sample_iter(&Alphanumeric)
    .take(8)
    .map(char::from)
    .collect()
}

rustler::init!(
    "Elixir.Siwe",
    [
        from_str,
        to_str,
        validate_sig,
        validate_time,
        validate,
        parse_if_valid_sig,
        parse_if_valid_time,
        parse_if_valid,
        generate_nonce
    ]
);
