#[cfg(test)]
mod tests {
    use deno_core::{serde_json, serde_v8, v8, JsRuntime, RuntimeOptions};

    use crate::api::js_call;

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

    #[test]
    fn test() {
        let mut runtime = JsRuntime::new(RuntimeOptions::default());

        // Evaluate some code
        let code = "let a = 1+4; a*2";
        let output: serde_json::Value = eval(&mut runtime, code).expect("Eval failed");

        println!("Output: {output:?}");

        let expected_output = serde_json::json!(10);
        assert_eq!(expected_output, output);
    }

    #[test]
    fn test2() {
        let code = "let a = 1+4; a*2";
        let out = js_call::dynamic_js_call(code.to_owned());
        println!("output is {out}");

        let code = r"
        let json = {
            'a': 1,
            'b': 2,
            'c': 3
        };
        json
        ";
        let out = js_call::dynamic_js_call(code.to_owned());
        println!("output is {out}");

        let code = r"
        let json = {
            'a': 1,
            'b': 2,
            'c': 3
        };
        json['a']
        ";
        let out = js_call::dynamic_js_call(code.to_owned());
        println!("output is {out}");
    }
}
