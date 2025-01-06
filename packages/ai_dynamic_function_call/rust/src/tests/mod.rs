#[cfg(test)]
mod tests {
    use std::ffi::CString;

    use crate::api::js_call;
    use deno_core::{serde_json, serde_v8, v8, JsRuntime, RuntimeOptions};
    use pyo3::prelude::*;

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

    #[test]
    fn test3() -> PyResult<()> {
        // 初始化 Python 解释器
        Python::with_gil(|py| {
            // 执行 Python 代码
            let script = r#"
def say_hello(name):
    return f"Hello, {name}!"
    "#;
            let c_string = CString::new(script).expect("CString::new failed");

            // 执行 Python 脚本
            py.run(c_string.as_c_str(), None, None)?;
            let name = CString::new("say_hello").expect("CString::new failed");

            // 调用 Python 函数
            let func = py.eval(name.as_c_str(), None, None)?;
            let result: String = func.call1(("python",))?.extract()?;

            // 输出结果
            println!("{}", result);
            Ok(())
        })
    }

    #[test]
    fn test4() -> PyResult<()> {
        // 初始化 Python 解释器
        Python::with_gil(|py| {
            // 执行 Python 代码
            let script = r#"
import json

def extract_json_obj(json_obj,name):
    json_obj = json.loads(json_obj)
    return str(json_obj[name])
    "#;
            let c_string = CString::new(script).expect("CString::new failed");

            // 执行 Python 脚本
            py.run(c_string.as_c_str(), None, None)?;
            let name = CString::new("extract_json_obj").expect("CString::new failed");

            // 调用 Python 函数
            let func = py.eval(name.as_c_str(), None, None)?;
            let result: String = func.call1(("{\"a\":100}", "a"))?.extract()?;

            // 输出结果
            println!("{}", result);
            Ok(())
        })
    }
}
