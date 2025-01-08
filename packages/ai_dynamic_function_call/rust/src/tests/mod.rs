#[cfg(test)]
mod tests {
    use std::{ffi::CString, fs};

    use crate::api::js_call;
    use deno_core::{
        error::AnyError,
        extension,
        futures::FutureExt,
        op2, serde_json,
        serde_v8::{self},
        v8, JsRuntime, ModuleCodeBytes, ModuleLoadResponse, ModuleLoader, ModuleSource,
        ModuleSourceCode, ModuleType, RequestedModuleType, RuntimeOptions,
    };
    use pyo3::prelude::*;

    struct SimpleModuleLoader;

    impl ModuleLoader for SimpleModuleLoader {
        fn resolve(
            &self,
            specifier: &str,
            _referrer: &str,
            _kind: deno_core::ResolutionKind,
        ) -> Result<deno_core::ModuleSpecifier, AnyError> {
            Ok(deno_core::ModuleSpecifier::parse(specifier)?)
        }

        fn load(
            &self,
            module_specifier: &deno_core::ModuleSpecifier,
            _maybe_referrer: Option<&deno_core::ModuleSpecifier>,
            _is_dyn_import: bool,
            _requested_module_type: RequestedModuleType,
        ) -> ModuleLoadResponse {
            let url = module_specifier.clone();

            ModuleLoadResponse::Async(
                async move {
                    // 使用 reqwest 下载模块
                    let response = reqwest::get(url.as_str()).await?;
                    let source = response.text().await?;
                    // Ok(ModuleSource {
                    //     code: source.into_bytes(),
                    //     module_type: ModuleType::JavaScript,
                    //     code_cache: None,
                    //     module_url_specified: url.to_string().into(),
                    //     module_url_found: url.to_string(),
                    // })
                    let b = ModuleCodeBytes::Boxed(source.into_bytes().into_boxed_slice());
                    let ms = ModuleSourceCode::Bytes(b);
                    Ok(ModuleSource::new(ModuleType::JavaScript, ms, &url, None))
                }
                .boxed_local(),
            )
        }
    }

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

    /// panic
    #[test]
    fn deno_core_test1() -> Result<(), AnyError> {
        // 创建 Deno 的 JavaScript 运行时
        let mut runtime = JsRuntime::new(RuntimeOptions {
            module_loader: Some(std::rc::Rc::new(deno_core::FsModuleLoader)),
            ..Default::default()
        });

        // JavaScript 代码，加载 docx 模块并解析 .docx 文件
        let js_code = r#"
            import { Document, Packer } from "https://deno.land/x/docx@latest/mod.ts";
    
            async function parseDocx() {
                const doc = new Document({
                    sections: [
                        {
                            children: [
                                {
                                    children: [
                                        {
                                            text: "Hello, Rust!",
                                        },
                                    ],
                                },
                            ],
                        },
                    ],
                });
    
                const buffer = await Packer.toBuffer(doc);
                return new Uint8Array(buffer);
            }
    
            parseDocx();
        "#;

        let rt = tokio::runtime::Runtime::new()?;

        // 加载并运行 JavaScript 模块
        let result = rt.block_on(async { runtime.execute_script("parseDocx.js", js_code) })?;
        println!("Result: {:?}", result);

        Ok(())
    }

    #[tokio::test]
    async fn deno_core_test2() -> Result<(), Box<dyn std::error::Error>> {
        let module_loader = SimpleModuleLoader;

        // 创建 JsRuntime
        let mut runtime = JsRuntime::new(RuntimeOptions {
            module_loader: Some(std::rc::Rc::new(module_loader)),
            ..Default::default()
        });

        // 定义入口模块
        let main_module = "https://unpkg.com/docx@9.1.0/build/index.umd.js";

        let m = deno_core::ModuleSpecifier::parse(main_module)?;

        // 加载模块
        let module_id = runtime.load_main_es_module(&m).await?;
        runtime.mod_evaluate(module_id).await?;

        Ok(())
    }

    #[op2]
    #[buffer]
    fn op_read_docx(#[string] p: String) -> Vec<u8> {
        let content = fs::read(p).unwrap();
        content
    }

    #[op2(fast)]
    pub fn op_add(a: i32, b: i32) -> i32 {
        a + b
    }

    /// not work
    #[tokio::test]
    async fn deno_core_test3() -> Result<(), Box<dyn std::error::Error>> {
        extension!(ext, ops = [op_read_docx]);

        // 创建 JsRuntime
        let mut runtime = JsRuntime::new(RuntimeOptions {
            extensions: vec![ext::init_ops_and_esm()],
            ..Default::default()
        });

        runtime.execute_script(
            "init",
            r#"
            globalThis.TextDecoder = TextDecoder;
            console.log(typeof TextDecoder);
            "#,
        )?;

        runtime.execute_script(
            "[mammoth.browser.min.js]",
            include_str!("./mammoth.browser.min.js").to_string(),
        )?;

        runtime.execute_script(
            "main",
            r#"
                globalThis.setTimeout = (fn, ms) => {
                    // 立即执行
                    fn();
                };

                console.log("mammoth  is :", mammoth);

                (async () => {
                
                    const buffer = Deno.core.ops.op_read_docx("C:/Users/xiaoshuyui/Desktop/模板.docx");
                    console.log("buffer read ok");
                    console.log("Raw buffer:", buffer);
                    try {
                        console.log("into func");
                        const arrayBuffer = buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength);
                        const result = await mammoth.extractRawText({ arrayBuffer: arrayBuffer });
                        console.log("Extracted text:", result.value);
                        console.log("func done");
                    } catch (error) {
                        console.log("error is :" + error);
                    }
    
                })();
                "#,
        )?;

        Ok(())
    }
}
