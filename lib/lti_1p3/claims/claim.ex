defprotocol Lti_1p3.Claims.Claim do
  @doc """
  Returns the key for a given claim

  ## Examples
      iex> get_key(%Lti_1p3.Claims.Claim{})
      "https://purl.imsglobal.org/spec/lti/claim/some_claim"
  """
  def get_key(claim)

  @doc """
  Returns the value for a given claim
  """
  def get_value(claim)
end
