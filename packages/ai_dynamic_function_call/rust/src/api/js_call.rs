use deno_core::{serde_json, serde_v8, v8, JsRuntime, RuntimeOptions};
use flutter_rust_bridge::frb;

use super::enums::ReturnType;

fn eval(context: &mut JsRuntime, code: &'static str) -> Result<serde_json::Value, String> {
    let res = context.execute_script("<anon>", code);
    match res {
        Ok(global) => {
            let scope = &mut context.handle_scope();
            let local = v8::Local::new(scope, global);
            // Deserialize a `v8` object into a Rust type using `serde_v8`,
            // in this case deserialize to a JSON `Value`.
            let deserialized_value = serde_v8::from_v8::<serde_json::Value>(scope, local);

            match deserialized_value {
                Ok(value) => Ok(value),
                Err(err) => Err(format!("Cannot deserialize value: {err:?}")),
            }
        }
        Err(err) => Err(format!("Evaling error: {err:?}")),
    }
}

#[frb(sync)]
pub fn dynamic_js_call(code: String) -> String {
    dynamic_js_call_with_return_type(code).0
}

#[frb(sync)]
pub fn dynamic_js_call_with_return_type(code: String) -> (String, ReturnType) {
    let mut context = JsRuntime::new(RuntimeOptions::default());
    let code_ref: &'static str = Box::leak(code.into_boxed_str());
    let res = eval(&mut context, code_ref);
    if let Ok(value) = res {
        match value {
            serde_json::Value::Null => {
                return ("null".to_string(), ReturnType::Null);
            }
            serde_json::Value::Bool(b) => {
                return (b.to_string(), ReturnType::Bool);
            }
            serde_json::Value::Number(number) => {
                return (number.to_string(), ReturnType::Number);
            }
            serde_json::Value::String(s) => {
                return (s, ReturnType::String);
            }
            serde_json::Value::Array(vec) => {
                if let Ok(json_string) = serde_json::to_string(&vec) {
                    return (json_string, ReturnType::Array);
                }
                return ("null".to_string(), ReturnType::Null);
            }
            serde_json::Value::Object(map) => {
                if let Ok(json_string) = serde_json::to_string(&map) {
                    return (json_string, ReturnType::Object);
                }
                return ("null".to_string(), ReturnType::Null);
            }
        }
    }

    ("null".to_string(), ReturnType::Null)
}
