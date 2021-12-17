defmodule Crux.Interaction.Response do
  @moduledoc ~S"""
  Allows you to compose interaction responses.

  First componse the response wanted through the `with_` functions, then pass / pipe
  the resulting data to the relevant function of the "Response Types" group.

  Notes:
  - Multiple calls of the same `with_`  function will override the previous set value.
  - You can pass `nil` to one of the `with_` functions to clear a previously set value.

  ### Examples


  ```elixir
  # Send an ephemeral text response
  with_content("Hello there")
  |> with_flags(1 <<< 6)
  |> channel_message()

  # Update a message
  with_content("Current state: #{state}")
  |> update_message()

  # Offer choices as response to an autocomplete interaction
  with_choices([%{choice: "One", 1}, %{choice: "Two", 2}, %{choice: "Four", 4}])
  |> autocomplete_result()

  # Open a modal
  # MODALS ARE NOT RELEASED / AVAILABLE YET.
  with_custom_id("custom_id")
  |> with_components(
    ActionRow.new(
      InputText.new(InputText.text_style_short(), "input_text_1", "What is your name?")
    )
  )
  |> modal()

  ```
  """
  @moduledoc since: "0.1.0"

  # Available response types
  @pong 1
  @channel_message 4
  @deferred_channel_message 5
  @deferred_update_message 6
  @update_message 7
  @autocomplete_result 8
  @modal 9

  @doc """
  Generates a response that acknowledges a ping.

  > Only valid as response to `Ping` interactions.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec pong() :: Crux.Rest.interaction_response()
  def pong() do
    %{type: @pong}
  end

  @doc """
  Generates a response that responds to an interaction with a message.

  > Not valid for autocomplete interactions.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec channel_message(message_data() | modal_data()) :: Crux.Rest.interaction_response()
  def channel_message(data) do
    %{type: @channel_message, data: data}
  end

  @doc """
  Generates a response that acknowledges an interaction and displays a loading state to the user.
  A response must be sent later manually.

  > Not valid for autocomplete interactions.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec deferred_channel_message() :: Crux.Rest.interaction_response()
  def deferred_channel_message() do
    %{type: @deferred_channel_message}
  end

  @doc """
  Generates a response that acknowledges a component interaction and displays \*no\* loading state to the user.
  An update must be sent later manually.

  > Only valid as response to component interactions.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec deferred_update_message() :: Crux.Rest.interaction_response()
  def deferred_update_message() do
    %{type: @deferred_update_message}
  end

  @doc """
  Generates a response that updates the message the component was attached to.

  > Only valid as response to component interactions.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec update_message(message_data()) :: Crux.Rest.interaction_response()
  def update_message(data) do
    %{type: @update_message, data: data}
  end

  @doc """
  Generates a response that displays the user choices to chose from.

  > Only valid as a response to auto complete interactions.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec autocomplete_result(autocomplete_data()) :: Crux.Rest.interaction_response()
  def autocomplete_result(data) do
    %{type: @autocomplete_result, data: data}
  end

  @doc """
  Generates a response that displays a modal to the user.

  **MODALS ARE NOT RELEASED / AVAILABLE YET.**

  > Not valid as response to a modal interaction.
  """
  @doc since: "0.1.0"
  @doc section: :response
  @spec modal(modal_data()) :: Crux.Rest.interaction_response()
  def modal(data) do
    %{type: @modal, data: data}
  end

  @typedoc """
  A choice to be used in `with_choices/1`,2.

  Limits:
  - `:name` - Length must be in `[1,100]`.
  - `:value` - If string, length must be in `[1,100]`, otherwise for integer and double value must be in `[-2^53,+2^53]`.

  For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-choice-structure).
  """
  @typedoc since: "0.1.0"
  @type choice :: %{name: String.t(), value: String.t() | integer() | float()}

  @typedoc """
  Data used to respond to an autocomplete interaction.

  Limits:
  - `:choices` - Max of 25 in length

  For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-autocomplete).
  """
  @typedoc since: "0.1.0"
  @type autocomplete_data() :: %{
          choices: [choice()]
        }

  @doc """
  The choices to provide.
  """
  @doc since: "0.1.0"
  @doc section: :autocomplete
  @spec with_choices(autocomplete_data(), [choice()]) :: autocomplete_data()
  def with_choices(data \\ %{}, choices)
      when is_nil(choices)
      when is_list(choices) do
    _put(data, :choices, choices)
  end

  @typedoc """
  Used when responding to an interaction with a message.

  For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-messages).
  """
  @typedoc since: "0.1.0"
  @type message_data :: %{
          tts: boolean(),
          content: String.t(),
          embeds: [Crux.Rest.embed_options()],
          allowed_mentions: %{
            parse: [roles_or_users_or_everyone :: String.t()],
            roles: [Crux.Structs.Snowflake.t()],
            users: [Crux.Structs.Snowflake.t()]
          },
          flags: non_neg_integer(),
          components: [Crux.Interaction.Component.t() | Crux.Rest.component()],
          attachments: [%{id: Crux.Structs.Snowflake.t()}]
        }

  @typedoc """
  Used when responding to an interaction with a modal.

  **MODALS ARE NOT RELEASED / AVAILABLE YET.**

  For more information see the [Discord Developer Documentation]().
  """
  @typedoc since: "0.1.0"
  @type modal_data :: %{
          custom_id: String.t(),
          components: [Crux.Interaction.Component.t() | Crux.Rest.component()]
        }

  @doc """
  The custom id to use.

  **MODALS ARE NOT RELEASED / AVAILABLE YET.**
  """
  @doc since: "0.1.0"
  @doc section: :modal
  @spec with_custom_id(modal_data(), String.t()) :: modal_data()
  def with_custom_id(data \\ %{}, custom_id)
      when is_nil(custom_id)
      when is_binary(custom_id) do
    _put(data, :custom_id, custom_id)
  end

  @doc """
  Whether the message content should use text-to-speech.
  """
  @doc since: "0.1.0"
  @doc section: :message
  @spec with_tts(message_data(), tts :: boolean() | nil) :: message_data()
  def with_tts(data \\ %{}, tts)
      when is_nil(tts)
      when is_boolean(tts) do
    _put(data, :tts, tts)
  end

  @doc """
  The message content to use.
  """
  @doc since: "0.1.0"
  @doc section: :message
  @spec with_content(message_data(), content :: String.t() | nil) :: message_data()
  def with_content(data \\ %{}, content)
      when is_nil(content)
      when is_binary(content) do
    _put(data, :content, content)
  end

  @doc """
  The embeds to use, may be up to 10.
  """
  @doc since: "0.1.0"
  @doc section: :message
  @spec with_embeds(message_data(), embeds :: [embed :: Crux.Rest.embed_options()] | nil) ::
          message_data()
  def with_embeds(data \\ %{}, embeds)
      when is_nil(embeds)
      when is_list(embeds) do
    _put(data, :embeds, embeds)
  end

  @doc """
  Controls what (kind of) mentions to resolve from the content.

  For more information see the [Discord Developer Documentation](https://discord.com/developers/docs/resources/channel#allowed-mentions-object-allowed-mentions-reference).
  """
  @doc since: "0.1.0"
  @doc section: :message
  @spec with_allowed_mentions(
          message_data(),
          allowed_mentions ::
            %{
              parse: [roles_or_users_or_everyone :: String.t()],
              roles: [Crux.Structs.Snowflake.t()],
              users: [Crux.Structs.Snowflake.t()]
            }
            | nil
        ) :: message_data()
  def with_allowed_mentions(data \\ %{}, allowed_mentions)
      when is_nil(allowed_mentions)
      when is_map(allowed_mentions) do
    _put(data, :allowed_mentions, allowed_mentions)
  end

  @doc """
  Message flags to use.
  """
  @doc since: "0.1.0"
  @doc section: :message
  @spec with_flags(message_data(), flags :: non_neg_integer() | nil) :: message_data()
  def with_flags(data \\ %{}, flags)
      when is_nil(flags)
      when is_integer(flags) and flags >= 0 do
    _put(data, :flags, flags)
  end

  @doc """
  The attachments to keep on the message.

  Not setting this means that all attachments will be kept.
  An empty list means that all attachments will be removed.

  > Only relevant when updating a message.
  """
  @doc since: "0.1.0"
  @doc section: :message
  @spec with_attachments(message_data(), attachments :: [%{id: Crux.Structs.Snowflake.t()}] | nil) ::
          message_data()
  def with_attachments(data \\ %{}, attachments)
      when is_nil(attachments)
      when is_list(attachments) do
    _put(data, :attachments, attachments)
  end

  @doc """
  The components to use.

  Available in modals and messages.
  """
  @doc since: "0.1.0"
  @doc section: :multiple
  @spec with_components(
          message_data(),
          Crux.Interaction.Component.t() | Crux.Rest.component()
        ) :: message_data()
  @spec with_components(
          modal_data(),
          Crux.Interaction.Component.t() | Crux.Rest.component()
        ) :: modal_data()
  def with_components(data \\ %{}, components)
      when is_nil(components)
      when is_list(components) do
    _put(data, :components, components)
  end

  defp _put(data, key, nil) do
    Map.delete(data, key)
  end

  defp _put(data, key, value) do
    Map.put(data, key, value)
  end
end
