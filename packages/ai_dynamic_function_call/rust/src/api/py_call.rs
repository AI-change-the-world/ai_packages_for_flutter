use flutter_rust_bridge::frb;
use pyo3::{types::PyAnyMethods, PyResult, Python};

use super::enums::ReturnType;

/// example:
/// ```python
/// import json
/// def extract_json_obj(json_obj,name):
///     json_obj = json.loads(json_obj)
///     return str(json_obj[name])
/// ```
#[derive(Debug)]
pub struct PyCallObj {
    pub return_type: ReturnType,
    pub function_name: String,
    pub script: String,
    pub args: Vec<String>,
}

impl PyCallObj {
    pub fn new(
        return_type: ReturnType,
        function_name: String,
        script: String,
        args: Vec<String>,
    ) -> PyCallObj {
        PyCallObj {
            return_type,
            function_name,
            script,
            args,
        }
    }

    #[frb(ignore)]
    pub fn exec(&self) -> PyResult<String> {
        Ok(Python::with_gil(|py| {
            let c_str_script = std::ffi::CString::new(self.script.clone()).expect("cstr Error");
            py.run(c_str_script.as_c_str(), None, None)
                .expect("run Error");
            let name = std::ffi::CString::new(self.function_name.clone()).expect("cstr Error");

            let func = py.eval(name.as_c_str(), None, None).expect("func error");
            let result: String;
            if self.args.is_empty() {
                result = func
                    .call0()
                    .expect("call error")
                    .extract()
                    .expect("extract error");
            } else {
                result = func
                    .call1((self.args.clone(),))
                    .expect("call error")
                    .extract()
                    .expect("extract error");
            }

            result
        }))
    }
}

#[frb(sync)]
pub fn dynamic_py_call(py_call: PyCallObj) -> String {
    let rs = py_call.exec();
    match rs {
        Ok(result) => result,
        Err(err) => {
            println!("[rust pycall error] {:?}", err);
            "Error".to_string()
        }
    }
}
