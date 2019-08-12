using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


public class SmoothNormal : MonoBehaviour
{
    public static void MeshNormalAverage(Mesh _mesh)
    {
        Dictionary<Vector3, List<int>> _map = new Dictionary<Vector3, List<int>>();

        for (int v = 0; v < _mesh.vertexCount; v++)
        {
            if (!_map.ContainsKey(_mesh.vertices[v]))
            {
                _map.Add(_mesh.vertices[v], new List<int>());
            }
            _map[_mesh.vertices[v]].Add(v);
        }

        Vector3[] _normals = _mesh.normals;
        Vector3 _normal;

        foreach (var _p in _map)
        {
            _normal = Vector3.zero;

            foreach (var _n in _p.Value)
            {
                _normal += _mesh.normals[_n];
            }

            _normal /= _p.Value.Count;

            foreach (var _n in _p.Value)
            {
                _normals[_n] = _normal;
            }
        }

        Vector4[] _tangents = _mesh.tangents;

        for (int i = 0; i < _normals.Length; i++)
        {
            _tangents[i] = new Vector4(_normals[i].x, _normals[i].y, _normals[i].z, 0);
        }
        _mesh.tangents = _tangents;

        //_mesh.normals = normals;
    }

    [MenuItem("Tools/Build Smoothed Normal Mesh")]
    public static void Build()
    {
        Material _mat;

        _mat = new Material(Shader.Find("KD/Outline_Tangent"));
        _mat.hideFlags = HideFlags.HideAndDontSave;

        GameObject _o = Selection.activeTransform.gameObject;
        if (_o == null)
        {
            Debug.Log("Select Object");
            return;
        }
        else
        {
            if (_o.GetComponent<MeshFilter>() != null)
            {
                Mesh _m = Instantiate(_o.GetComponent<MeshFilter>().sharedMesh);
                MeshNormalAverage(_m);
                AssetDatabase.CreateAsset(_m, "Assets/SmoothNormalMesh/" + _o.name + "_smooth" + ".asset");

            }
            else if (_o.transform.GetComponent<SkinnedMeshRenderer>() != null)
            {
                Mesh _m = Instantiate(_o.GetComponent<SkinnedMeshRenderer>().sharedMesh);
                MeshNormalAverage(_m);
                AssetDatabase.CreateAsset(_m, "Assets/SmoothNormalMesh/" + _o.name + "_smooth" + ".asset");
            }
            else
            {
                Debug.Log("No mesh");
                return;
            }
        }
    }
}
