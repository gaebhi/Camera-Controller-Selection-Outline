using UnityEngine;

[ExecuteInEditMode]
public class PostProcess : MonoBehaviour
{
	public Material PostProcessMaterial;
	void OnRenderImage( RenderTexture _src, RenderTexture _dest )
	{
		Graphics.Blit( _src, _dest, PostProcessMaterial);
	}
}
