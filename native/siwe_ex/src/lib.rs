use ethers_core::{types::H160, utils::to_checksum};
use hex::FromHex;
use http::uri::Authority;
use iri_string::types::UriString;
use rand::distributions::Alphanumeric;
use rand::{thread_rng, Rng};
use rustler::NifStruct;
use siwe::{Message, TimeStamp, Version};
use std::str::FromStr;

#[derive(NifStruct)]
#[module = "Siwe"]
pub struct Parsed {
    pub domain: String,
    pub address: String,
    pub statement: Option<String>,
    pub uri: String,
    pub version: String,
    pub chain_id: u64,
    pub nonce: String,
    pub issued_at: String,
    pub expiration_time: Option<String>,
    pub not_before: Option<String>,
    pub request_id: Option<String>,
    pub resources: Vec<String>,
}

impl Parsed {
    pub fn to_eip4361_message(&self) -> Result<Message, String> {
        let mut next_resources: Vec<UriString> = Vec::new();
        for resource in &self.resources {
            let x = UriString::from_str(resource)
                .map_err(|e| format!("Failed to parse resource: {}", e.to_string()))?;
            next_resources.push(x);
        }

        Ok(Message {
            domain: Authority::from_str(&self.domain)
                .map_err(|e| format!("Bad domain: {}", e.to_string()))?,
            address: <[u8; 20]>::from_hex(self.address.chars().skip(2).collect::<String>())
                .map_err(|e| format!("Bad address: {}", e.to_string()))?,
            statement: self.statement.clone(),
            uri: UriString::from_str(&self.uri)
                .map_err(|e| format!("Bad uri: {}", e.to_string()))?,
            version: Version::from_str(&self.version)
                .map_err(|e| format!("Bad version: {}", e.to_string()))?,
            chain_id: self.chain_id,
            nonce: self.nonce.to_string(),
            issued_at: TimeStamp::from_str(&self.issued_at)
                .map_err(|e| format!("Failed to convert issued at: {}", e))?,
            expiration_time: to_timestamp(&self.expiration_time),
            not_before: to_timestamp(&self.not_before),
            request_id: self.request_id.clone(),
            resources: next_resources,
        })
    }
}

fn from_timestamp(maybe_timestamp: &Option<TimeStamp>) -> Option<String> {
    match maybe_timestamp {
        None => None,
        Some(t) => Some(t.to_string()),
    }
}

fn to_timestamp(maybe_string: &Option<String>) -> Option<TimeStamp> {
    match maybe_string {
        None => None,
        Some(s) => match TimeStamp::from_str(&s) {
            Err(_) => None,
            Ok(t) => Some(t),
        },
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
        issued_at: m.issued_at.to_string(),
        expiration_time: from_timestamp(&m.expiration_time),
        not_before: from_timestamp(&m.not_before),
        request_id: m.request_id,
        resources: m.resources.into_iter().map(|s| s.to_string()).collect(),
    }
}

#[rustler::nif]
fn parse(message: String) -> Result<Parsed, String> {
    Ok(message_to_parsed(
        Message::from_str(&message).map_err(|e| format!("Failed to parse: {}", e))?,
    ))
}

#[rustler::nif]
fn to_str(message: Parsed) -> Result<String, String> {
    Ok(message
        .to_eip4361_message()
        .map_err(|e| format!("Failed to marshal to string: {}", e))?
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
fn parse_if_valid(message: String, sig: String) -> Result<Parsed, String> {
    let s = <[u8; 65]>::from_hex(sig.chars().skip(2).collect::<String>())
        .map_err(|e| format!("Failed to convert sig to bytes: {}", e))?;

    match Message::from_str(&message) {
        Err(e) => Err(e.to_string()),
        Ok(m) => match m.verify_eip191(&s) {
            Ok(_) => {
                if m.valid_now() {
                    Ok(message_to_parsed(m))
                } else {
                    Err("Invalid time".to_string())
                }
            }

            Err(e) => Err(e.to_string()),
        },
    }
}

#[rustler::nif]
fn generate_nonce() -> String {
    thread_rng()
        .sample_iter(&Alphanumeric)
        .take(11)
        .map(char::from)
        .collect()
}

rustler::init!(
    "Elixir.Siwe",
    [
        parse,
        to_str,
        validate_sig,
        validate,
        parse_if_valid,
        generate_nonce
    ]
);
