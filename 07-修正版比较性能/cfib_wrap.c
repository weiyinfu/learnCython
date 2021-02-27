#include <Python.h>
#include "cfib.h"

static PyObject *wrap_fib(PyObject *self, PyObject *args)
{
    int arg;
    double result;

    if (!PyArg_ParseTuple(args, "i:fib", &arg))
        return NULL;

    result = cfib(arg);

    return Py_BuildValue("f", result);
}

static PyMethodDef funcs[] = {
    {"fib", wrap_fib, METH_VARARGS, "Calculate the nth fibonnaci number."},
    {NULL, NULL, 0, NULL} /* sentinel */
};
static struct PyModuleDef cModPyDem =
{
    PyModuleDef_HEAD_INIT,
    "cModPyDem", /* name of module */
    "",          /* module documentation, may be NULL */
    -1,          /* size of per-interpreter state of the module, or -1 if the module keeps state in global variables. */
    funcs
};
PyMODINIT_FUNC PyInit_cfib(void)
{
   return PyModule_Create(&cModPyDem);
}
