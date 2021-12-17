defmodule Crux.Interaction.ResponseTest do
  use ExUnit.Case, async: true
  alias Crux.Interaction.Response

  doctest Response

  describe "response (wrappers)" do
    test "pong" do
      assert %{type: 1} == Response.pong()
    end

    test "channel_message" do
      assert %{type: 4, data: %{some: :data}} == Response.channel_message(%{some: :data})
    end

    test "deferred_channel_message" do
      assert %{type: 5} == Response.deferred_channel_message()
    end

    test "deferred_update_message" do
      assert %{type: 6} == Response.deferred_update_message()
    end

    test "update_message" do
      assert %{type: 7, data: %{some: :data}} == Response.update_message(%{some: :data})
    end

    test "autocomplete_result" do
      assert %{type: 8, data: %{some: :data}} == Response.autocomplete_result(%{some: :data})
    end

    test "modal" do
      assert %{type: 9, data: %{some: :data}} == Response.modal(%{some: :data})
    end
  end

  describe "autocomplete" do
    test "with_choices" do
      choices = [
        %{name: "Foo", value: "foo"},
        %{name: "Bar", value: "bar"},
        %{name: "Baz", value: "baz"}
      ]

      assert %{choices: choices} == Response.with_choices(choices)
    end

    test "with_choices overwrites" do
      response = Response.with_choices([%{name: "Foo", value: "foo"}])

      assert %{choices: [%{name: "Foo", value: "foo"}]} == response

      assert %{choices: [%{name: "Bar", value: "bar"}]} ==
               Response.with_choices(response, [%{name: "Bar", value: "bar"}])
    end

    test "with_choices nil deletes" do
      response = Response.with_choices([%{name: "Foo", value: "foo"}])

      assert %{choices: [%{name: "Foo", value: "foo"}]} == response

      assert %{} == Response.with_choices(response, nil)
    end
  end

  describe "modal" do
    test "with_custom_id" do
      assert %{custom_id: "123"} == Response.with_custom_id("123")
    end

    test "with_custom_id overwrites" do
      response = Response.with_custom_id("123")

      assert %{custom_id: "123"} == response

      assert %{custom_id: "456"} == Response.with_custom_id(response, "456")
    end

    test "with_custom_id nil deletes" do
      response = Response.with_custom_id("123")

      assert %{custom_id: "123"} == response

      assert %{} == Response.with_custom_id(nil)
    end
  end

  test "with_tts" do
    assert %{tts: true} == Response.with_tts(true)
  end

  test "with_content" do
    assert %{content: "foo"} == Response.with_content("foo")
  end

  test "with_embeds" do
    assert %{embeds: [%{description: "bar"}]} == Response.with_embeds([%{description: "bar"}])
  end

  test "with_allowed_mentions" do
    assert %{allowed_mentions: %{parse: []}} == Response.with_allowed_mentions(%{parse: []})
  end

  test "with_flags" do
    assert %{flags: 64} == Response.with_flags(64)
  end

  test "with_files" do
    assert %{files: [{"content", "name.txt"}]} == Response.with_files([{"content", "name.txt"}])
  end

  test "with_files empty files deletes too" do
    response = Response.with_files([{"hello there", "file.txt"}])

    assert %{files: [{"hello there", "file.txt"}]} == response

    assert %{} = Response.with_files([])
  end

  test "with_attachments" do
    assert %{attachments: []} == Response.with_attachments([])
  end

  test "with_components" do
    assert %{components: []} == Response.with_components([])
  end

  test "message with multiple properties" do
    response =
      Response.with_tts(false)
      |> Response.with_content("hello there")
      |> Response.with_embeds([%{description: "foo"}])
      |> Response.with_allowed_mentions(%{parse: []})
      |> Response.with_flags(64)
      |> Response.with_attachments([])
      |> Response.with_components([])

    assert %{
             tts: false,
             content: "hello there",
             embeds: [%{description: "foo"}],
             allowed_mentions: %{parse: []},
             flags: 64,
             attachments: [],
             components: []
           } == response
  end
end
